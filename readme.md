# :grinning: Why so serious? :grinning:

This repository is intended for people who want to run
CNMF-E on orchestra (specifically right now o2). This code
simplifies many of the cnmfe initialization steps so that it
will effectively find cells and remove background signals.

## Instructions

1. Please copy `cnmfe.config` into the directory you'd like to extract. It contains important thresholds for detecting neurons and merging duplicate cells.
2. Change the parameters in the **config file** to best suit your needs.
3. Make sure that cnmfe is downloaded and saved on your orchestra account.
4. make sure the code paths to cnmfe and this repo are properly pointed to in your **config file**.
5. change the paths to your code in `batch-cnmfe`, and change the mail-user to your own email

## Future plans

Eventually, we want to be able to run parameter scans to identify the most optimal parameters for identifying cells.
`cnmfe_grid_search.m` will eventually be populated to accomplish this goal.
