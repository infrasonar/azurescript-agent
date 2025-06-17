# InfraSonar Azure Agent

A simple agent to monitor Azure.

This collector has a two checks:
- `backup` with one type: `jobs`.
- `agent` with one type: `agent`.


## Check: backup

### Type: jobs

This type is **required** and may have multiple items.

Metric                  | Type    | Required | Description
----------------------- | ------- | -------- | -----------
name                    | string  | yes      | WorkloadName of the Backup Job.
Status                  | string  | yes      | Status of the Backup Job, for example: `"Completed"`.
StartTime               | integer | yes      | Start time of the Backup Job as Unix timestamp in seconds.
EndTime                 | integer | yes      | End time of the Backup Job as Unix timestamp in seconds.
Duration                | float   | yes      | Total duration in seconds of the Backup Job.
BackupManagentmentType  | string  | no       | Backup Management type.


## Check: agent

### Type: agent

This type is **required** and it must have exactly one item. There is an `max` age configured for this check.

Metric    | Type    | Required | Description
--------- | ------- | -------- | -----------
name      | string  | yes      | Name of the agent. (`azurescript`)
info      | string  | no       | Free format info.
version   | string  | no       | Version of the agent/script.
