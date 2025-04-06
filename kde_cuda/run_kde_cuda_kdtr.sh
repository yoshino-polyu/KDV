#!/bin/bash
sh -c "build/bin/kde_cuda_kdtr 1 pntsSim200000.csv maskSim160000.asc 0 1 0 redwood_SEQ.asc redwood_GPU.asc > redwood_LOG_old_$(date +'%m-%d-%H:%M').log"