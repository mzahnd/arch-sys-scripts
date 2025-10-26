#!/usr/bin/env python3

import asyncio
import re

from i3ipc import Connection

OUTPUT_MAIN = "eDP-1"
OUTPUT_IGNORE = ("xroot-0", "VIRTUAL-1", "DP-1", "HDMI-2")  # Outputs to ignore


def get_focused_monitor(i3, primary, secondary):
    workspaces = i3.get_workspaces()

    for workspace in workspaces:
        if workspace.focused and workspace.name in (primary,secondary):
            return workspace.name

    return ""


def get_temporary_workspace(i3):
    workspaces = i3.get_workspaces()
    numbered_workspaces = filter(lambda w: w.name[0].isdigit(), workspaces)
    numbers = list(
        map(
            lambda w: int(re.search(r"^[0-9]+", w.name).group(0)),
            numbered_workspaces,
        )
    )

    for i in range(1, max(numbers) + 2):
        if i not in numbers:
            return i


def swap_workspace_names(i3, primary, secondary):
    """Swap workspaces names"""

    tmp_workspace = get_temporary_workspace(i3)

    i3.command(f"rename workspace {primary} to {tmp_workspace}")
    i3.command(f"rename workspace {secondary} to {primary}")
    i3.command(f"rename workspace {tmp_workspace} to {secondary}")


def swap_workspaces_outputs(i3, primary, secondary):
    """Swap workspaces from one monitor to another"""

    i3.command(f"focus output {primary.name}")
    i3.command(f"move workspace to output {secondary.name}")

    i3.command(f"focus output {secondary.name}")
    i3.command(f"move workspace to output {primary.name}")

    # Show both workspaces again on screen and focus the one which used to be
    # "secondary"
    i3.command(f"workspace {secondary.current_workspace}")
    i3.command(f"workspace {primary.current_workspace}")


def main():
    i3 = Connection()

    outputs = i3.get_outputs()

    primary_output = None
    secondary_output = None

    for output in outputs:
        print(output.name)
        if output.name == OUTPUT_MAIN:
            primary_output = output
        elif output.name not in OUTPUT_IGNORE:
            secondary_output = output

    if not primary_output or not secondary_output:
        return

    focused = get_focused_monitor(
        i3, primary_output.current_workspace, secondary_output.current_workspace
    )

    # Swap variable names if needed
    if focused != primary_output.current_workspace:
        tmp = primary_output
        primary_output = secondary_output
        secondary_output = tmp

    swap_workspace_names(
        i3, primary_output.current_workspace, secondary_output.current_workspace
    )

    swap_workspaces_outputs(i3, primary_output, secondary_output)


if __name__ == "__main__":
    main()
