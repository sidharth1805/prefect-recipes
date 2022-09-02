"""Using context, mapped, and unmapped in an example flow
"""

from typing import Any, List

from prefect import flow, get_run_logger, task, unmapped
from prefect.context import get_run_context


@task
def my_task(element: Any, greeting: str) -> Any:
    """`my_task` will be mapped over each `element` in `my_elements`,
    each run of that task receiving the same `greeting` argument, because
    you can't map over a camel
    """
    logger = get_run_logger()
    task_run_context = get_run_context()

    logger.info(
        f"{greeting} from {task_run_context.task_run.name}!"
        f" look at this {type(element).__name__} 😦: {element!r}"
    )


@flow(name="I wanna look at my elements")
def my_elementary_flow(my_elements: List):
    logger = get_run_logger()
    flow_run_context = get_run_context()

    logger.info(
        f"👋 Welcome to {flow_run_context.flow_run.name}!"
        " ... wanna check out some elements real fast?!"
    )

    my_task.map(my_elements, greeting=unmapped("hi"))


if __name__ == "__main__":
    my_elements = [42, "¡yo-yo!", 3.14159265 ** (0.5), False]

    my_elementary_flow(my_elements)
