from prefect.client import get_client
from prefect.context import get_run_context
from prefect.orion.schemas.states import Scheduled
from prefect import flow, task, get_run_logger
import time
import asyncio

# Recipe Ideas
# - Wait for one flow to complete before triggering another flow
# --- It would be amazing if I could do something like sub_flow.submit(wait_for=other_flows]), but its doesnt seem like this is possible. It seems this is only possible with tasks. Could anyone help?

# - Concurrent subflows
# --- It is mentioned in the docs that sub_flows block execution of the parent flow, this is a huge problem for us as our entire pipeline is predicated on being able to run these things concurrently.

# - Sounds like they need concurrent subflows alongside subflows that waif for. -

@flow
def sync_subflow_a():
    print('Flow runs before all')

@flow
def async_subflow_1():
    print('Flow async after a completes')

def async_subflow_2():
    print('Flow async after a completes')

def sync_subflow_b():
    print('Flow runs only after 2 completes')

# Possible Solution?
# @flow
# def main_flow():

#     flow_ctx = sub_flow(return_state=True)

    # wait for subflow to be complet
#     while flow_ctx.dict()['type'] != 'COMPLETED':
#         time.sleep(1)
    
#     api call for dependent subflow

#     next_sub_flow()

