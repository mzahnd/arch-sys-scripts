#!/usr/bin/python3

import argparse
import http.server
import ipaddress
import logging
import os
import posixpath
import socketserver
import sys
import urllib.parse

"""Extremely simple HTTP server to run local and test the site."""

# Default values. Can be modified by CLIArguments.parse()
HOST_ADDRESS = "localhost"
PORT = 8080

PACMAN_PACKAGES = "/var/cache/pacman/pkg/"
PACMAN_DATABASES = "/var/lib/pacman/sync/"

LOGGING_LEVEL = logging.INFO  # Either INFO or DEBUG
# LOGGING_LEVEL = logging.DEBUG  #

# Improvements from:
# https://gist.github.com/mdonkers/63e115cc0c79b4f6b8b3a6b797e485c7
# https://github.com/python/cpython/blob/3.11/Lib/http/server.py


class CLIArguments:
    def __init__(self):
        self.args = None

        self.parser = argparse.ArgumentParser(
            prog="Paclan Server",
            description="Serve local pacman packages and databases over LAN",
            epilog="(C) Martin E. Zahnd - 2022",
        )
        self.add_arguments()

    def add_arguments(self):
        self.parser.add_argument(
            "-a",
            "--host",
            help="Address to serve the http server. Default: %(default)s",
            type=str,
            metavar="<address>",
            default=HOST_ADDRESS,
        )
        self.parser.add_argument(
            "-p",
            "--port",
            help="Port for HOST_ADDRESS. Default: %(default)s",
            type=int,
            metavar="<port>",
            default=PORT,
        )
        self.parser.add_argument(
            "-d",
            "--cachedir",
            help="Pacman package cache location. Default: %(default)s",
            type=str,
            metavar="<dir>",
            default=PACMAN_PACKAGES,
        )
        self.parser.add_argument(
            "-b",
            "--dbpath",
            help="Pacman databases location. Default: %(default)s",
            type=str,
            metavar="<dir>",
            default=PACMAN_DATABASES,
        )
        self.parser.add_argument(
            "-v",
            "--verbose",
            help="Debug mode. Default: INFO",
            action="store_true",
        )

    def parse(self):

        self.args = self.parser.parse_args()

        # It's always nicer to see all the cli errors at the same time
        # instead of fixing them one by one by re-running the script
        success = True
        success &= self.verify_host_address()
        success &= self.verify_port()
        success &= self.verify_cachedir()
        success &= self.verify_databases()
        success &= self.verify_debug_level()
        if not success:
            sys.exit(2)

    def verify_host_address(self):
        global HOST_ADDRESS

        if not self.args:
            return False
        elif not self.args.host:
            return True

        # 'localhost' is a valid address
        if not str(self.args.host) == "localhost":
            try:
                ipaddress.ip_address(self.args.host)
                HOST_ADDRESS = self.args.host
            except ValueError:
                self.parser.print_usage()
                print("Invalid address provided to --host-address.")
                return False

        return True

    def verify_port(self):
        global PORT

        if not self.args:
            return False
        elif not self.args.port:
            return True

        if 1 <= int(self.args.port) <= 65535:
            PORT = self.args.port
        else:
            self.parser.print_usage()
            print("Invalid port provided to --port.")
            return False

        return True

    def verify_cachedir(self):
        global PACMAN_PACKAGES

        if not self.args:
            return False
        elif not self.args.cachedir:
            return True

        if not os.path.isdir(self.args.cachedir):
            self.parser.print_usage()
            print("Invalid location provided to --dbpath: Not a directory")
            return False
        elif not os.access(self.args.cachedir, os.R_OK | os.X_OK):
            self.parser.print_usage()
            print(
                "Invalid location provided to --dbpath: "
                "We need both read and execute permissions"
            )
            return False

        PACMAN_PACKAGES = self.args.cachedir

        return True

    def verify_databases(self):
        global PACMAN_DATABASES

        if not self.args:
            return False
        elif not self.args.dbpath:
            return True

        if not os.path.isdir(self.args.dbpath):
            self.parser.print_usage()
            print("Invalid location provided to --dbpath: Not a directory")
            return False
        elif not os.access(self.args.dbpath, os.R_OK | os.X_OK):
            self.parser.print_usage()
            print(
                "Invalid location provided to --dbpath: "
                "We need both read and execute permissions"
            )
            return False

        PACMAN_DATABASES = self.args.dbpath

        return True

    def verify_debug_level(self):
        global LOGGING_LEVEL

        if not self.args:
            return False
        elif not self.args.verbose:
            return True

        LOGGING_LEVEL = logging.DEBUG
        print("Level!")
        return True


class HttpRequestHandler(http.server.SimpleHTTPRequestHandler):
    def send_error(self, code, message=None, explain=None):
        logging.debug(
            "Code: %(code)d."
            " Message: %(msg)s."
            " Explain: %(explain)s."
            % {"code": code, "msg": message, "explain": explain}
        )

        http.server.SimpleHTTPRequestHandler.send_error(
            self, code, message, explain
        )

    def do_GET(self):
        logging.debug(
            "Path: %(path)s"
            "\n--- Header start ---"
            "\n%(header)s"
            "\n--- Header end ---" % {"path": self.path, "header": self.headers}
        )

        return http.server.SimpleHTTPRequestHandler.do_GET(self)

    def translate_path(self, path):
        logging.debug(
            "Path: %(path)s" % {"path": path},
        )

        # Drop query parameters
        path = path.split("?", 1)[0]
        path = path.split("#", 1)[0]
        # Explicit trailing slash when normalizing
        trailing_slash = path.rstrip().endswith("/")

        try:
            path = urllib.parse.unquote(path, errors="surrogatepass")
        except UnicodeDecodeError:
            path = urllib.parse.unquote(path)

        path = posixpath.normpath(path)
        words = path.split("/")
        words = filter(None, words)

        if path[-4:] == ".zst" or path[-8:] == ".zst.sig":
            path = PACMAN_PACKAGES
        elif path[-3:] == ".db":
            path = PACMAN_DATABASES
        else:
            path = self.directory

        for word in words:
            if os.path.dirname(word) or word in (os.curdir, os.pardir):
                # Ignore components that are not a simple file/directory name
                continue

            path_joined = os.path.join(path, word)
            if os.path.islink(path_joined):
                # Ignore symbolic links
                logging.debug(
                    "Symbolic link detected: %(path)s" % {"path": path_joined}
                )
                path = self.directory
                break

            path = path_joined

        if trailing_slash:
            path += "/"

        logging.debug("Translated path: %(path)s" % {"path": path})

        return path


def run():
    with http.server.ThreadingHTTPServer(
        (HOST_ADDRESS, PORT), HttpRequestHandler
    ) as server:
        logging.info(
            "Serving on %(host)s:%(port)d"
            % {"host": HOST_ADDRESS, "port": PORT}
        )
        server.serve_forever()


if __name__ == "__main__":
    args = CLIArguments()
    args.parse()

    logging.basicConfig(
        format="[%(asctime)s]"
        " [%(levelname)s]"
        " [%(funcName)s]"
        " %(message)s",
        level=LOGGING_LEVEL,
        datefmt="%Y-%m-%dT%H:%M:%S%z",
    )

    logging.debug(
        "CLI Arguments:\n"
        "\tHost: %(host)s\n"
        "\tPort: %(port)d\n"
        "\tCache dir: %(pkgs)s\n"
        "\tDatabases dir: %(db)s\n"
        "\tLevel: %(level)s"
        % {
            "host": HOST_ADDRESS,
            "port": PORT,
            "pkgs": PACMAN_PACKAGES,
            "db": PACMAN_DATABASES,
            "level": LOGGING_LEVEL,
        }
    )

    try:
        run()
    except KeyboardInterrupt:
        logging.info("Aborted by user.")

    logging.info("Stopped httpd.")
