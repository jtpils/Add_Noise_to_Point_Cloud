# Add_Noise_v001
## Overview
Add the following three types of noises to point cloud
- Gaussian
- Poisson
- Spike

## Usage
`./addNoise [input_file] [output_file] [ratio_of_adding_noise] [param_spec_to_noise] [noise_option]`

`./addNoise [.ply] [.spbr] [0.1] [0.001] [-g]`

- -g : Gaussian
- -p : Poisson
- -s : Spike

- Add noise with 10 percent. (0.1(argv[3])*100)


## Three types of noises
### 1. Gaussian (AddNoise::Gaussian)
sigma = BB_length * 0.001(argv[4])

### 2. Poisson (AddNoise::Poisson)
lamda = BB_length * 0.001(argv[4])

### 3. Spike (AddNoise::Spike)
