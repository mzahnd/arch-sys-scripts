#!/usr/bin/env python3

import asyncio
import re

from i3ipc.aio import Connection

OUTPUT_MAIN = "eDP-1"
OUTPUT_IGNORE = ("xroot-0", "VIRTUAL-1", "DP-1", "HDMI-2")  # Outputs to ignore


async def get_focused_monitor(i3, primary, secondary):
    workspaces = await i3.get_workspaces()

    for workspace in workspaces:
        if workspace.name == primary and workspace.focused is True:
            return primary
        elif workspace.name == secondary and workspace.focused is True:
            return secondary

    return ""


async def get_temporary_workspace(i3):
    workspaces = await i3.get_workspaces()
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


async def swap_workspace_names(i3, primary, secondary):
    """Swap workspaces names"""

    tmp_workspace = await get_temporary_workspace(i3)

    await i3.command(
        "rename workspace {old} to {new}".format(old=primary, new=tmp_workspace)
    )

    await i3.command(
        "rename workspace {old} to {new}".format(
            old=secondary,
            new=primary,
        )
    )

    await i3.command(
        "rename workspace {old} to {new}".format(
            old=tmp_workspace, new=secondary
        )
    )


async def swap_workspaces_outputs(i3, primary, secondary):
    """Swap workspaces from one monitor to another"""

    await i3.command("focus output {output}".format(output=primary.name))
    await i3.command(
        "move workspace to output {output}".format(output=secondary.name)
    )

    await i3.command("focus output {output}".format(output=secondary.name))
    await i3.command(
        "move workspace to output {output}".format(output=primary.name)
    )

    # Show both workspaces again on screen and focus the one which used to be
    # "secondary"
    await i3.command(
        "workspace {name}".format(name=secondary.current_workspace)
    )
    await i3.command("workspace {name}".format(name=primary.current_workspace))


async def main():
    i3 = await Connection().connect()

    outputs = await i3.get_outputs()

    primary_output = None
    secondary_output = None

    for output in outputs:
        print(output.name)
        if output.name == OUTPUT_MAIN:
            primary_output = output
        elif output.name in OUTPUT_IGNORE:
            continue
        else:
            secondary_output = output

    if secondary_output is None:
        return

    focused = await get_focused_monitor(
        i3, primary_output.current_workspace, secondary_output.current_workspace
    )

    # Swap variable names if needed
    if focused != primary_output.current_workspace:
        tmp = primary_output
        primary_output = secondary_output
        secondary_output = tmp

    await swap_workspace_names(
        i3, primary_output.current_workspace, secondary_output.current_workspace
    )

    await swap_workspaces_outputs(i3, primary_output, secondary_output)


if __name__ == "__main__":
    asyncio.run(main())
