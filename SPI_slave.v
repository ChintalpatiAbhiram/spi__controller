`timescale 1ns / 1ps

module SPI_slave(
    spi_clk,
    clk,
    tx_data,
    rx_data,
    MISO,
    MOSI,
    CS,
    reset
    );
    
    input spi_clk,reset,CS,MOSI,clk;
    output reg [7:0] rx_data;
    input [7:0] tx_data;
    output MISO;
    
    localparam IDLE = 2'b00;
    localparam TRANSFER = 2'b01;
    
    reg [1:0] state, next_state;
    reg [7:0] tx_shift_reg;
    reg [7:0] rx_shift_reg;
    reg spi_clk_prev;
    
    // EDGE DETECTION
    always@(posedge clk)
    begin
        spi_clk_prev <= spi_clk;
    end
    
    
    wire spi_rise_pulse = ~spi_clk_prev & spi_clk;
    wire spi_fall_pulse = spi_clk_prev & ~spi_clk;
    
    assign MISO = tx_shift_reg[7];
    
    always@(posedge clk or posedge reset)
    begin
    if (reset)
        state <= IDLE;
    else
        state <= next_state;
    end
    
    // NEXT-STATE LOGIC
    
    always@(*)
    begin
        next_state = state;
        
        case(state)
            
            IDLE:
            if (CS == 0)
                next_state = TRANSFER;
            else
                next_state = IDLE;
            
            TRANSFER:
            if (CS)
                next_state = IDLE;
            else
                next_state = TRANSFER;
            
            default: next_state = IDLE;
        endcase
    end
    
    // DATA PATH LOGIC
    
    always@(posedge clk or posedge reset)
    begin
        if(reset)
        begin
            tx_shift_reg <= 0;
            rx_shift_reg <= 0;
            rx_data <= 0;
        end
        
        else if (state == IDLE && !CS)
        begin
            tx_shift_reg <= tx_data;
            rx_shift_reg <= 0;
        end
        
        else
            begin
            case(state)
                
                
                TRANSFER:
                begin
                if(spi_fall_pulse)
                    begin
                    tx_shift_reg <= tx_shift_reg << 1;
                    end
                    
                if(spi_rise_pulse)
                    rx_shift_reg <= {rx_shift_reg[6:0], MOSI};
                    
                end
                
                IDLE:
                begin
                    if(CS)
                        rx_data <= rx_shift_reg;
                end
                default: ;
            endcase
        end
    end
    
endmodule
