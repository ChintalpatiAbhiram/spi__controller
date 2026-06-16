# SPI Master-Slave Controller (Mode 0)
# Overview

This project implements a full-duplex SPI (Serial Peripheral Interface) Master and Slave in Verilog HDL supporting SPI Mode 0 (CPOL = 0, CPHA = 0).

The design was developed from scratch to understand the SPI protocol at the RTL level, including finite state machine (FSM) design, shift registers, clock generation, edge detection, and synchronous data transfer.

The implementation was verified using simulation in Vivado with a self-checking testbench connecting the SPI master and slave.

# Features

1. SPI Mode 0 (CPOL = 0, CPHA = 0)
2. 8-bit full-duplex data transfer
3. Independent SPI Master and SPI Slave modules
4. Parameterizable SPI clock divider
5. full duplex mode
6. Master-controlled Chip Select (CS)

# Verification

In Mode 0, the transmitter updates data on the falling edge of the SPI clock while the receiver samples data on the rising edge, ensuring stable data before sampling.

The master and slave were connected together in simulation.

Example transaction:

Master TX : 11010010
Slave  TX : 01101101

Simulation Result:

Master RX : 01101101
Slave  RX : 11010010

This verifies successful full-duplex communication between the master and slave.

# Future improvements

Planned enhancements include:

1. Support for all SPI modes (CPOL/CPHA)
2. Configurable word length
3. Multi-byte transfers
4. Transmit and receive ready/done flags
