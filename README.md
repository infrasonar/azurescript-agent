# InfraSonar Azure Agent

A simple agent to monitor Azure.

This collector has a single check: `backup` and two types: `jobs` and `agent`.


## Type: jobs

This type is **required** and may have multiple items.

Metric                  | Type    | Required | Description
----------------------- | ------- | -------- | -----------
name                    | string  | yes      | WorkloadName of the Backup Job.
Status                  | string  | yes      | Status of the Backup Job, for example: `"Completed"`.
StartTime               | integer | yes      | Start time of the Backup Job as Unix timestamp in seconds.
EndTime                 | integer | yes      | End time of the Backup Job as Unix timestamp in seconds.
Duration                | float   | yes      | Total duration in seconds of the Backup Job.
BackupManagentmentType  | string  | no       | Backup Management type.


## Type agent

This type is **optional** and is given, it must have exactly one item.

Metric    | Type    | Required | Description
--------- | ------- | -------- | -----------
name      | string  | yes      | Name of the agent. (`azurescript`)
info      | string  | no       | Free format info.
version   | string  | no       | Version of the agent/script.
# azurescript-agent
