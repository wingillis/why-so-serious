# why so serious?

## Important Information about how CNMF_E works

Descriptions of the data formats and functions utilized by the package

## The Source2D Class (aka `neuron`)

Important vars (all subcomponents of the Source2D object):

| Name | Desc |
|------|------|
| A | contains the spatial mask of each detected neuron, in vector form |
| C | contains a modeled trace each detected neuron exhibits |
| C_raw | contains the raw fluorescence (df/f?) from the detected neuron |
| Cn | some sort of correlation? |
| S | theoretical number of spikes exhibited at any given point for the neuron |

## extract cell traces

Make sure the parameters used for detecting cells are conditioned well for the
data you present to it.

Parameters that need to be set properly:
- `min_pnr`
- `min_corr`
- `min_pixel`

Check these with `cnmfe_show_pnr`
