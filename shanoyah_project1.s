

.data 0x10000000
prompt_user_command: .asciiz "Please enter Encode (e or E), Decode(d or D), Terminate(t or T): " # prompt user input command
.data 0x10000050
prompt_user_input_encode: .asciiz "Please input message to encode with the bits in Desending order from (D11 -> D1): " # prompt user input command
.data 0x100000b0
prompt_terminate: .asciiz "Program Terminated"
.data 0x100000d0
prompt_hamming_syndrome: .asciiz "4-bit Hamming syndrome (p8, p4, p2, p1): "
.data 0x10000100
prompt_user_input_decode: .asciiz "Please input message to decode with the bits in Desending order from (D11 -> P0): " # prompt user input command
.data 0x10000200
p8: .asciiz " P8 = "    # 0x10000200
.data 0x10000210
p4: .asciiz " P4 = "    # 0x10000210
.data 0x10000220
p2: .asciiz " P2 = "    # 0x10000220
.data 0x10000230
p1: .asciiz " P1 = "    # 0x10000230
.data 0x10000240
p0: .asciiz " P0 = "    # 0x10000240
.data 0x10000250
encoded: .asciiz "Encoded Message:  "      # 0x10000250
.data 0x10000270
unvalidated_code: .asciiz "Unvalidated Decoded Data: " #0x10000270
.data 0x10000290
decoded: .asciiz "Decoded Message: "       # 0x10000290

.data 0x100002B0
error: .asciiz "Unable to compute for than 1 error detected "       # 0x100002B0
.data 0x100002F0
true: .asciiz "Total parity - PASS "                                # 0x100002B0
.data 0x10000320
false: .asciiz "Total parity - FAIL  "                              # 0x100002B0

.data 0x10001000
user_command:   .space 2 # determines if the user wants to encode/ decode or terminate program
.space 14
input_string_message: .space 16  #buffer for the input 11 bit string from user     0x10001010
.data 0x10001020
raw_string_to_decode:  .word  0  #buffer for the input 16 bit string from user     0x10001020
.data 0x10001030
input_codeword: .word  0b00000000000 # the input data/codeword (converted from input string)         0x10001030

.data 0x10001040
p_bit1: .space 1 # Parity bit 1                                                            0x10001040
        .space 3 # to keep 4 bit alignment
p_bit2: .space 1 # Parity bit 2                                                            0x10001044
        .space 3 # to keep 4 bit alignment
p_bit4: .space 1 # Parity bit 3                                                            0x10001048
        .space 3 # to keep 4 bit alignment
p_bit8: .space 1 # Parity bit 4                                                            0x1000104c
        .space 3
p_bit0: .space 1 #Total Parity (p0) validity check (1 for False/error, 0 for True/valid)   0x10001050
        .space 3 # to keep 4 bit alignment
.data 0x10001060
bit_16_encode: .word 0 #0b0000000000000000 # full 16-bit encoded codeword from data                          0x10001060
.data 0x10001070
bit_11_extracted: .word  0   #unvalidated extracted 11-bit data                        0x10001070
.data 0x10001080
corrected_codeword: .word 0 #fixed/corrected codeword                                    0x10001080
                    #(If there is no error, this is a duplicate of the input codeword.)
.data 0x10001090                  
output: .word 0 # final correct output data                                               0x10001090
.data 0x10001100
bit_4_ham: .space 4 # combined 4-bit Hamming syndrome                                      0x10001100

.text

main:
# prompt user for input
    #la $a0, prompt_user_command   # prints Please enter Encode ("e"  "E"),  Decode("d"  "D"),  Terminate("t"  "T")
    lui $a0, 0x1000
    ori $a0, $a0, 0x0000
    #li $v0, 4             # prints the string 
    lui $v0, 0x0000
    ori $v0, $v0, 0x0004
    syscall

# read string from console
    #li $v0, 8                # set system call code to read string
    lui $v0, 0x0000
    ori $v0, $v0, 0x0008
    #la $a0, user_command     # load address of user_command
    lui $a0, 0x1000
    ori $a0, $a0, 0x1000
    #li $a1, 1              # set maximum length of input string
    lui $a1, 0x0000
    ori $a1, $a1, 0x0002
    syscall                  # read the string

# evlauate command
    #la $a0, user_command     # load address of input string
    lui $a0, 0x1000
    ori $a0, $a0, 0x1000
    lw  $s0, 0($a0)           # store user input in $v0
    add $zero, $zero, $zero   # nop

# If user Input 'e' or 'E'
    #li $t0, 'e'  #
    lui $t0, 0x0000
    ori $t0, $t0, 0x0065
    #li $t1, 'E'  #
    lui $t1, 0x0000
    ori $t1, $t1, 0x0045
    beq $s0, $t0, Encode   # if input == 'e' Branch to Encode
    add $zero, $zero, $zero   # nop
    beq $s0, $t1, Encode   # if input == 'E' Branch to Encode   
    add $zero, $zero, $zero   # nop

# If user Input 'd' or 'D'
    #li $t0, 'd'  #
    lui $t0, 0x0000
    ori $t0, $t0, 0x0064
    #li $t1, 'D'  #
    lui $t1, 0x0000
    ori $t1, $t1, 0x0044
    beq $s0, $t0, Decode   # if input == 'd' Branch to Decode
    add $zero, $zero, $zero   # nop
    beq $s0, $t1, Decode   # if input == 'D' Branch to Decode  
    add $zero, $zero, $zero   # nop

# If user Input 't' or 'T'
    #li $t0, 't'  #
    lui $t0, 0x0000
    ori $t0, $t0, 0x0074
    #li $t1, 'T'  #
    lui $t1, 0x0000
    ori $t1, $t1, 0x0054
    beq $s0, $t0, Terminate   # if input == 't' Branch to Terminate
    add $zero, $zero, $zero   # nop
    beq $s0, $t1, Terminate   # if input == 'T' Branch to Terminate 
    add $zero, $zero, $zero   # nop 


    




# Function/Module Name:
# Summary of Purpose:
# Input/Stored Value Requirements:
# Values Stored/Returned:
Convert_Message:
 # prompt user for input
        #la $a0, prompt_user_input   # prints "Please input message to Encode" 
        lui $a0, 0x1000
        ori $a0, $a0, 0x0050
        #li $v0, 4             # prints the string 
        lui $v0, 0x0000
        ori $v0, $v0, 0x0004
        syscall

# read string from console
        #li $v0, 8                # set system call code to read string
        lui $v0, 0x0000
        ori $v0, $v0, 0x0008
        #la $a0, user_command     # load address of user_command
        lui $a0, 0x1000
        ori $a0, $a0, 0x1010
        #li $a1, 1              # set maximum length of input string
        add $a1, $a1, $zero
        syscall                  # read the string


# converting string to Word
        #la $a0, input_string       # load the address of the message into $a0
        lui $a0, 0x1000
        ori $a0, $a0, 0x1010
        #la $a1, input_codeword:             # load the address of the buffer into $a1
        lui $a1, 0x1000
        ori $a1, $a1, 0x1030

        #li $t0, 0   Current bit
        lui $t0, 0x0000
        ori $t0, $t0, 0x0000
        #li $t1, 0  count
        lui $t1, 0x0000
        ori $t1, $t1, 0x0000
        addi $t5, $zero, 11
     loop_msg:
        lb $t2, 0($a0)      # Load the next character from the string
        beq $t5, $zero, done   # If we've reached the end of the string, exit the loop
        add $zero, $zero, $zero   # nop
        sll $t0, $t0, 1     # Shift the current bit to the left
        addi $t1, $t1, 1    # Increment the count of bits
        addi $s6, $zero, 0x31  # s6 = '1' (0x31)
        beq $t2, $s6, setbit # If the character is '1', set the current bit to 1
        add $zero, $zero, $zero   # nop
        j next              # Else, get next character in the string
        add $zero, $zero, $zero   # nop
     setbit:
        ori $t0, $t0, 1     # Set the current bit to 1
     next:
        addi $a0, $a0, 1    # increment to the next character in the string
        addi $t5, $t5, -1
        j loop_msg   
        add $zero, $zero, $zero   # nop           
         
    done:
        #sll $t0, $t0, 4

        #store result in memory
        sw $t0, 0($a1)

        jr $ra
        add $zero, $zero, $zero   # nop


Convert_Code:
 # prompt user for input
        #la $a0, prompt_user_input   # prints "Please input message to Encode" 
        lui $a0, 0x1000
        ori $a0, $a0, 0x0100
        #li $v0, 4             # prints the string 
        lui $v0, 0x0000
        ori $v0, $v0, 0x0004
        syscall

# read string from console
        #li $v0, 8                # set system call code to read string
        lui $v0, 0x0000
        ori $v0, $v0, 0x0008
        #la $a0, user_command     # load address of string to decode
        lui $a0, 0x1000
        ori $a0, $a0, 0x1010
        #li $a1, 1              # set maximum length of input string
        add $a1, $a1, $zero
        syscall                  # read the string


# converting string to Word
        #la $a0, input_string       # load the address of the message into $a0
        lui $a0, 0x1000
        ori $a0, $a0, 0x1010
        #la $a1, input_codeword:             # load the address of the buffer into $a1
        lui $a1, 0x1000
        ori $a1, $a1, 0x1020

        #li $t0, 0   Current bit
        lui $t0, 0x0000
        ori $t0, $t0, 0x0000
        #li $t1, 0  count
        lui $t1, 0x0000
        ori $t1, $t1, 0x0000
        addi $t5, $zero, 16
     loop_code:
        lb $t2, 0($a0)      # Load the next character from the string
        beq $t2, $zero, done_code   # If we've reached the end of the string, exit the loop
        add $zero, $zero, $zero   # nop
        sll $t0, $t0, 1     # Shift the current bit to the left
        addi $t1, $t1, 1    # Increment the count of bits
        addi $s6, $zero, 0x31  # s6 = '1' (0x31)
        beq $t2, $s6, setbit_code # If the character is '1', set the current bit to 1
        add $zero, $zero, $zero   # nop
        j next_code              # Else, get next character in the string
        add $zero, $zero, $zero   # nop

     setbit_code:
        ori $t0, $t0, 1     # Set the current bit to 1
     next_code:
        addi $a0, $a0, 1    # increment to the next character in the string
        addi $t5, $t5, -1
        j loop_code  
        add $zero, $zero, $zero   # nop            
         
    done_code:
        #sll $t0, $t0, 4

        #store result in memory
        sw $t0, 0($a1)

        jr $ra
        add $zero, $zero, $zero   # nop


        
Parity_count:
        #addi $s1, $zero, 11     #counter for loop
        addi $s2, $zero, 1      #stores the value 1
        addi $v0, $zero, 0      # parity bits


    loop_count:
        beq $s1, $zero, done_count   #exit if at the end of the loop
        add $zero, $zero, $zero   # nop
        andi $s3, $s0, 1             #extract last bit and store in $s3

        beq $s3, $s2, increment_p    # if extracted bit equals 1 increment parity bit by one
        j next_count
        add $zero, $zero, $zero   # nop
    increment_p:
       addi $v0, $v0, 1              #add 1 to $v0s

        next_count:
        srl $s0, $s0, 1             # shift right by 1 to get the next value
        addi $s1, $s1, -1           #deincrement count 
        j loop_count
        add $zero, $zero, $zero   # nop

        done_count:

        andi $v0, $v0, 0x1          # parity value

        jr $ra
        add $zero, $zero, $zero   # nop


extract_bit:               # function
    srl $a0, $a0, $a1      # shift a0 right (a1)th times
    addi $t0, $zero, 1     # t0 = 1
    and $v0, $a0, $t0      # AND $a0 with 1 and store in v0
    jr $ra
    add $zero, $zero, $zero   # nop


print:
            add $v1, $zero, $ra
            lw $s0, 0($a0)
            add $zero, $zero, $zero   # nop
            addi $t3, $t1, -1  #index to extract
            addi $s7, $zero, 1 # stroes the value 1
          loop_print:
            beq $t1, $zero, done_print  #if count = 0 jump to done
            add $zero, $zero, $zero   # nop
            
            add $a0, $zero, $s0          # arugment for extract
            add $a1, $zero, $t3          # th element to be extracted
            jal extract_bit
            add $zero, $zero, $zero   # nop

            add $t2, $zero, $v0          # store extracted bit

            beq $t2, $zero, print_zero   #if extrated bit is 0 jump to print_zero
            add $zero, $zero, $zero   # nop
            addi $a0, $zero, 1
            #li $v0, 4             # prints the string 
            lui $v0, 0x0000
            ori $v0, $v0, 0x0001
            syscall

            j next_print
            add $zero, $zero, $zero   # nop

            print_zero:
              add $a0, $zero, $zero
              #li $v0, 4             # prints the string 
              lui $v0, 0x0000
              ori $v0, $v0, 0x0001
              syscall

            next_print:
              addi $t1, $t1, -1   # deincrement count 
              addi $t3, $t3, -1   # deincrement index

              j loop_print  
              add $zero, $zero, $zero   # nop        

            done_print:
          add $ra, $zero, $v1
      jr $ra
      add $zero, $zero, $zero   # nop

New_Line:
      # New line
        lui $a0, 0x0000
        ori $a0, $a0, 0x000a
        #li $v0, 11 # change line
        lui $v0, 0x0000
        ori $v0, $v0, 0x000b
        syscall

        jr $ra
        add $zero, $zero, $zero   # nop





################
##
##
##
#######
##
##
##
################



# Function/Module Name:
# Summary of Purpose:
# Input/Stored Value Requirements:
# Values Stored/Returned:
Encode:
        #la $a0, 10  # New line
        lui $a0, 0x0000
        ori $a0, $a0, 0x000a
        #li $v0, 11 # change line
        lui $v0, 0x0000
        ori $v0, $v0, 0x000b
        syscall

        lui $a1, 0x0000           # set maximum length of input string
        ori $a1, $a1, 0x000c
        jal Convert_Message
        add $zero, $zero, $zero   # nop
        or $zero, $zero, $zero #nop


# load the 11 bits word into a register t0
        lui, $a0, 0x1000         # load the address of the 11 bit message
        ori $a0, $a0, 0x1030     # load lower 16 bit of address
        lw $s0, 0($a0)           # store value at address
        add $zero, $zero, $zero   # nop
        lui, $t0, 0x0000         # load uper 16 bit of value 11 bit message
        or, $t0, $t0, $s0        # load lower 16 bit of value 11 bit message

# Initialize Parity Bits

        add $t1, $zero, $t1       # set p1 = 0
        add $t2, $zero, $t2       # set p2 = 0
        add $t3, $zero, $t3       # set p4 = 0
        add $t4, $zero, $t4       # set p8 = 0
        add $t5, $zero, $t5       # set the Total Parity (p0) to 0
# Calculate Parity Bits
        
        # Calculate p1
        andi $t1, $t0, 0x55B      # extract p1 parity bits
        add $s0, $zero, $t1       # set argument value for Parity_count
        addi $s1, $zero, 11     #counter for loop 

        jal Parity_count          # counts the number of 1's
        add $zero, $zero, $zero   # nop
        add $t1,$zero, $v0        # store the result from $v0 in $t1
        lui $a0, 0x1000
        ori $a0, $a0, 0x1040      #load address for parity p1
        sw $v0 0($a0)             # store P1 in memory

        # Calculate p2
        andi $t2, $t0, 0x66D      # extract p1 parity bits
        add $s0, $zero, $t2       # set argument value for Parity_count
        addi $s1, $zero, 11     #counter for loop

        jal Parity_count          # counts the number of 1's
        add $zero, $zero, $zero   # nop
        add $t2,$zero, $v0        # store the result from $v0 in $t2
        lui $a0, 0x1000
        ori $a0, $a0, 0x1044      #load address for parity p2
        sw $v0 0($a0)             # store P2 in memory
        add $zero, $zero, $zero   # nop

        # Calculate p4
        andi $t3, $t0, 0x78E      # extract p1 parity bits
        add $s0, $zero, $t3       # set argument value for Parity_count
        addi $s1, $zero, 11     #counter for loop

        jal Parity_count          # counts the number of 1's
        add $zero, $zero, $zero   # nop
        add $t3,$zero, $v0        # store the result from $v0 in $t3
        lui $a0, 0x1000
        ori $a0, $a0, 0x1048      #load address for parity p4
        sw $v0 0($a0)             # store P4 in memory
        add $zero, $zero, $zero   # nop

        # Calculate p8
        andi $t4, $t0, 0x7F0      # extract p1 parity bits
        add $s0, $zero, $t4       # set argument value for Parity_count
        addi $s1, $zero, 11     #counter for loop

        jal Parity_count          # counts the number of 1's
        add $zero, $zero, $zero   # nop
        add $zero, $zero, $zero   # nop
        add $t4,$zero, $v0        # store the result from $v0 in $t4
        lui $a0, 0x1000
        ori $a0, $a0, 0x104c      #load address for parity p8
        sw $v0 0($a0)             # store P8 in memory
        add $zero, $zero, $zero   # nop

# Build encoded Data

        add $t6, $zero, $zero      # stores combined value
        lui $a0, 0x1000           #load upper immediate address 11_bit_codeword
        ori $a0, $a0, 0x1030      #load lower immediate address 11_bit_codeword
        lw $s0, 0($a0)             # load value value into $t0
        add $zero, $zero, $zero   # nop
        add $a0, $zero, $t0        # $a0 = $t0
        

        #p1
        sll $t1, $t1, 1           # shift p1 by 1 place
        or $t6, $t6, $t1          # add it to combine using or
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
        #p2
        sll $t2, $t2, 2           # shift p2 by 2 place
        or $t6, $t6, $t2          # add it to combine using or

        #d1
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 0        # index to extract
        jal extract_bit           # branch to extra d1
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 3           # shift d1 by 3 place
        or $t6, $t6, $v0          # add it to combine using or

        #p3
        sll $t3, $t3, 4           # shift p3 by 4 place
        or $t6, $t6, $t3          # add it to combine using or

        #d2
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 1        # index to extract
        jal extract_bit           # branch to extra d2
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 5           # shift d2 by 5 place
        or $t6, $t6, $v0          # add it to combine using or

        #d3
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 2        # index to extract
        jal extract_bit           # branch to extra d3
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 6           # shift d3 by 6 place
        or $t6, $t6, $v0          # add it to combine using or

        #d4
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 3        # index to extract
        jal extract_bit           # branch to extra d4
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 7           # shift d4 by 7 place
        or $t6, $t6, $v0          # add it to combine using or

        #p4
        sll $t4, $t4, 8           # shift p3 by 4 place
        or $t6, $t6, $t4          # add it to combine using or

        #d5
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 4        # index to extract
        jal extract_bit           # branch to extra d5
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 9           # shift d5 by 9 place
        or $t6, $t6, $v0          # add it to combine using or

        #d6
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 5        # index to extract
        jal extract_bit           # branch to extra d6
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 10           # shift d6 by 10 place
        or $t6, $t6, $v0          # add it to combine using or

        #d7
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 6        # index to extract
        jal extract_bit           # branch to extra d7
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 11           # shift d7 by 11 place
        or $t6, $t6, $v0          # add it to combine using or

        #d8
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 7        # index to extract
        jal extract_bit           # branch to extra d8
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 12           # shift d8 by 12 place
        or $t6, $t6, $v0          # add it to combine using or

        #d9
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 8        # index to extract
        jal extract_bit           # branch to extra d9
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 13           # shift d9 by 13 place
        or $t6, $t6, $v0          # add it to combine using or

        #d10
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 9        # index to extract
        jal extract_bit           # branch to extra d10
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 14           # shift d10 by 14 place
        or $t6, $t6, $v0          # add it to combine using or

        #d11
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 10        # index to extract
        jal extract_bit           # branch to extra d11
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 15           # shift d11 by 15 place
        or $t6, $t6, $v0          # add it to combine using or

        lui $a1, 0x1000           #load upper immediate address full_16_bits
        ori $a1, $a1, 0x1060      #load lower immediate address full_16_bits
        sw $t6, 0($a1)

#Calculating Total Parity
        # Calculate p0
        add $t0, $zero, $t6       # copy in the 16 bits
        andi $t5, $t0, 0x7FFF      # extract p0 parity bits
        add $s0, $zero, $t5       # set argument value for Parity_count
        addi $s1, $zero, 15       #counter for loop 

        jal Parity_count          # counts the number of 1's
        add $zero, $zero, $zero   # nop
        add $zero, $zero, $zero   # nop
        add $t5,$zero, $v0        # store the result from $v0 in $t5
        lui $a0, 0x1000
        ori $a0, $a0, 0x1050      #load address for parity p5
        sw $t5 0($a0)             # store P5 in memory

# Combine Total Parity with final output
        #p1
        or $t6, $t6, $t5          # add it to combine using or
        #store result again
        lui $a1, 0x1000           #load upper immediate address full_16_bits
        ori $a1, $a1, 0x1060      #load lower immediate address full_16_bits
        sw $t6, 0($a1)

# Print Outputs Data
      jal New_Line       # Adds a new line
      add $zero, $zero, $zero   # nop

      #print p8  
      lui $a0, 0x1000
      ori $a0, $a0, 0x0200
      #li $v0, 4             # prints the string 
      lui $v0, 0x0000
      ori $v0, $v0, 0x0004
      syscall

           # address for p8 
      lui $a0, 0x1000           # upper immediate of address
      ori $a0, $a0, 0x104c      # lowe immediate of address
      addi $t1, $zero, 1        # length of string
      jal print
      add $zero, $zero, $zero   # nop

      jal New_Line       # Adds a new line
      add $zero, $zero, $zero   # nop

      #print p4  
      lui $a0, 0x1000
      ori $a0, $a0, 0x0210
      #li $v0, 4             # prints the string 
      lui $v0, 0x0000
      ori $v0, $v0, 0x0004
      syscall

        # address for p4 
      lui $a0, 0x1000           # upper immediate of address
      ori $a0, $a0, 0x1048      # lowe immediate of address
      addi $t1, $zero, 1        # length of string
      jal print
      add $zero, $zero, $zero   # nop

      jal New_Line       # Adds a new line
      add $zero, $zero, $zero   # nop

      #print p2  
      lui $a0, 0x1000
      ori $a0, $a0, 0x0220
      #li $v0, 4             # prints the string 
      lui $v0, 0x0000
      ori $v0, $v0, 0x0004
      syscall

           # address for p2
      lui $a0, 0x1000           # upper immediate of address
      ori $a0, $a0, 0x1044      # lowe immediate of address
      addi $t1, $zero, 1        # length of string
      jal print
      add $zero, $zero, $zero   # nop

      jal New_Line       # Adds a new line
      add $zero, $zero, $zero   # nop

      #print p1  
      lui $a0, 0x1000
      ori $a0, $a0, 0x0230
      #li $v0, 4             # prints the string 
      lui $v0, 0x0000
      ori $v0, $v0, 0x0004
      syscall

           # address for p1 
      lui $a0, 0x1000           # upper immediate of address
      ori $a0, $a0, 0x1040      # lowe immediate of address
      addi $t1, $zero, 1        # length of string
      jal print
      add $zero, $zero, $zero   # nop

      jal New_Line       # Adds a new line
      add $zero, $zero, $zero   # nop
      #print p0 
      lui $a0, 0x1000
      ori $a0, $a0, 0x0240
      #li $v0, 4             # prints the string 
      lui $v0, 0x0000
      ori $v0, $v0, 0x0004
      syscall

           # address for p0 
      lui $a0, 0x1000           # upper immediate of address
      ori $a0, $a0, 0x1050      # lowe immediate of address
      addi $t1, $zero, 1        # length of string
      jal print
      add $zero, $zero, $zero   # nop


      jal New_Line       # Adds a new line
      add $zero, $zero, $zero   # nop
      #print p0 
      lui $a0, 0x1000
      ori $a0, $a0, 0x0250
      #li $v0, 4             # prints the string 
      lui $v0, 0x0000
      ori $v0, $v0, 0x0004
      syscall

           # address for p0 
      lui $a0, 0x1000           # upper immediate of address
      ori $a0, $a0, 0x1060      # lowe immediate of address
      addi $t1, $zero, 16        # length of string
      jal print
      add $zero, $zero, $zero   # nop

      jal New_Line       # Adds a new line
      add $zero, $zero, $zero   # nop
      jal New_Line       # Adds a new line
      add $zero, $zero, $zero   # nop

      j main
      add $zero, $zero, $zero   # nop
    



extract_bit_d:               # function
    srl $a0, $a0, $a1      # shift a0 right (a1)th times
    addi $t0, $zero, 1     # t0 = 1
    and $s1, $a0, $t0      # AND $a0 with 1 and store in v0
    #return
    jr $ra
    add $zero, $zero, $zero   # nop


###########
##         ##
##          ##
##           ##
##            ##
##             ##
##            ##
##           ##
##         ##   
##       ##
#########


# Function/Module Name:
# Summary of Purpose:
# Input/Stored Value Requirements:
# Values Stored/Returned:
Decode:
         #la $a0, 10  # New line
        lui $a0, 0x0000
        ori $a0, $a0, 0x000a
        #li $v0, 11 # change line
        lui $v0, 0x0000
        ori $v0, $v0, 0x000b
        syscall

        lui $a1, 0x0000           # set maximum length of input string
        ori $a1, $a1, 0x011        # 11 in base 10
        jal Convert_Code
        add $zero, $zero, $zero   # nop

#Extract 11 bits and store at 0x1000 1070
        add $t6, $zero, $zero      # stores combined value
        lui $a0, 0x1000           #load upper immediate address 16_bit_codeword
        ori $a0, $a0, 0x1020      #load lower immediate address 16_bit_codeword
        lw $s0, 0($a0)             # load value value into $s0
        add $zero, $zero, $zero   # nop
        
        #d1
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores code value)
        addi $a1, $zero, 3        # index to extract
        jal extract_bit_d           # branch to extra d1
        add $zero, $zero, $zero   # nop
        sll $s1, $s1, 0           # shift d1 by 3 place
        or $t6, $t6, $s1          # add it to combine using or

        #d2
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 5        # index to extract
        jal extract_bit_d           # branch to extra d2
        add $zero, $zero, $zero   # nop
        sll $s1, $s1, 1           # shift d1 by 3 place
        or $t6, $t6, $s1          # add it to combine using or

        #d3
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 6        # index to extract
        jal extract_bit_d           # branch to extra d3
        add $zero, $zero, $zero   # nop
        sll $s1, $s1, 2           # shift d1 by 3 place
        or $t6, $t6, $s1          # add it to combine using or

        #d4
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 7        # index to extract
        jal extract_bit_d           # branch to extra d4
        add $zero, $zero, $zero   # nop
        sll $s1, $s1, 3           # shift d1 by 3 place
        or $t6, $t6, $s1          # add it to combine using or


        #d5
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 9        # index to extract
        jal extract_bit_d           # branch to extra d5
        add $zero, $zero, $zero   # nop
        sll $s1, $s1, 4           # shift d1 by 3 place
        or $t6, $t6, $s1          # add it to combine using or

        #d6
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero,  10       # index to extract
        jal extract_bit_d           # branch to extra d6
        add $zero, $zero, $zero   # nop
        sll $s1, $s1, 5           # shift d1 by 3 place
        or $t6, $t6, $s1          # add it to combine using or

        #d7
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 11        # index to extract
        jal extract_bit_d           # branch to extra d7
        add $zero, $zero, $zero   # nop
        sll $s1, $s1, 6           # shift d1 by 3 place
        or $t6, $t6, $s1          # add it to combine using or

        #d8
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 12        # index to extract
        jal extract_bit_d           # branch to extra d8
        add $zero, $zero, $zero   # nop
        sll $s1, $s1, 7           # shift d1 by 3 place
        or $t6, $t6, $s1          # add it to combine using or

        #d9
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 13        # index to extract
        jal extract_bit_d           # branch to extra d9
        add $zero, $zero, $zero   # nop
        sll $s1, $s1, 8           # shift d1 by 3 place
        or $t6, $t6, $s1          # add it to combine using or

        #d10
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 14        # index to extract
        jal extract_bit_d           # branch to extra d10
        add $zero, $zero, $zero   # nop
        sll $s1, $s1, 9           # shift d1 by 3 place
        or $t6, $t6, $s1          # add it to combine using or

        #d11
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 15        # index to extract
        jal extract_bit_d           # branch to extra d11
        add $zero, $zero, $zero   # nop
        sll $s1, $s1, 10           # shift d1 by 3 place
        or $t6, $t6, $s1          # add it to combine using or

        lui $a1, 0x1000           #load upper immediate address raw_11_bit
        ori $a1, $a1, 0x1070      #load lower immediate address raw_11_bit
        sw $t6, 0($a1)            # strore raw 11 bits in memory


# load the raw 11 bits word into a register t0
        lui, $a0, 0x1000         # load the address of the 11 bit message
        ori $a0, $a0, 0x1070     # load lower 16 bit of address
        lw $s0, 0($a0)           # store value at address
        add $zero, $zero, $zero   # nop
        lui, $t0, 0x0000         # load uper 16 bit of value 11 bit message
        or, $t0, $t0, $s0        # load lower 16 bit of value 11 bit message


# Extract 16 bit encoded code parity bits
        add $t6, $zero, $zero     # stores combined value
        lui $a0, 0x1000           #load upper immediate address 16_bit_codeword
        ori $a0, $a0, 0x1020      #load lower immediate address 16_bit_codeword
        lw $s0, 0($a0)            # load value value into $s0
        add $zero, $zero, $zero   # nop
        
        #p1 (16 bit encoded)
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores code value)
        addi $a1, $zero, 1        # index to extract
        jal extract_bit_d           # branch to extra p1
        add $zero, $zero, $zero   # nop
        #sll $v0, $v0, 0           # shift p1 by 0 place
        or $t6, $t6, $s1          # add it to combine using or

        #p2 (16 bit encoded)
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores code value)
        addi $a1, $zero, 2        # index to extract
        jal extract_bit_d           # branch to extra p2
        add $zero, $zero, $zero   # nop
        sll $s1, $s1, 1           # shift p1 by 1 place
        or $t6, $t6, $s1          # add it to combine using or

        #p4 (16 bit encoded)
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores code value)
        addi $a1, $zero, 4        # index to extract
        jal extract_bit_d           # branch to extra p1
        add $zero, $zero, $zero   # nop
        sll $s1, $s1, 2           # shift p4 by 2 place
        or $t6, $t6, $s1          # add it to combine using or

        #p8 (16 bit encoded)
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores code value)
        addi $a1, $zero, 8        # index to extract
        jal extract_bit_d           # branch to extra p8
        add $zero, $zero, $zero   # nop
        sll $s1, $s1, 3           # shift p8 by 3 place
        or $t6, $t6, $s1          # add it to combine using or

        lui $a0, 0x1000           # load immediate upper address for 4 bit hamming code
        ori $a0, $a0, 0x1100      # load immediate lower address for 4 bit hamming code
        sw $t6, 0($a0)            # store 4 bit hamming code in memory

        


# Calculate Unvalidated 11 bit data Parity Bits

# load the Unvalidated 11 bits word into a register t0
        lui, $a0, 0x1000         # load the address of the 11 bit message
        ori $a0, $a0, 0x1070     # load lower 16 bit of address
        lw $s0, 0($a0)           # store value at address
        add $zero, $zero, $zero   # nop
        lui, $t0, 0x0000         # load uper 16 bit of value 11 bit message
        or, $t0, $t0, $s0        # load lower 16 bit of value 11 bit message

# Initialize Parity Bits

        add $t1, $zero, $t1       # set p1 = 0
        add $t2, $zero, $t2       # set p2 = 0
        add $t3, $zero, $t3       # set p4 = 0
        add $t4, $zero, $t4       # set p8 = 0
        add $t5, $zero, $t5       # set the Total Parity (p0) to 0

        
# Calculate Parity Bits
        
        # Calculate p1 (Unvalidated 11)
        andi $t1, $t0, 0x55B      # extract p1 parity bits
        add $s0, $zero, $t1       # set argument value for Parity_count
        addi $s1, $zero, 11     #counter for loop 

        jal Parity_count          # counts the number of 1's
        add $zero, $zero, $zero   # nop
        add $t1,$zero, $v0        # store the result from $v0 in $t1
        lui $a0, 0x1000
        ori $a0, $a0, 0x1040      #load address for parity p1
        sw $v0 0($a0)             # store P1 in memory
 
        # Calculate p2 (Unvalidated 11)
        andi $t2, $t0, 0x66D      # extract p1 parity bits
        add $s0, $zero, $t2       # set argument value for Parity_count
        addi $s1, $zero, 11     #counter for loop

        jal Parity_count          # counts the number of 1's
        add $zero, $zero, $zero   # nop
        add $t2,$zero, $v0        # store the result from $v0 in $t2
        lui $a0, 0x1000
        ori $a0, $a0, 0x1044      #load address for parity p2
        sw $v0 0($a0)             # store P2 in memory
        add $zero, $zero, $zero   # nop

        # Calculate p4 (Unvalidated 11)
        andi $t3, $t0, 0x78E      # extract p1 parity bits
        add $s0, $zero, $t3       # set argument value for Parity_count
        addi $s1, $zero, 11     #counter for loop

        jal Parity_count          # counts the number of 1's
        add $zero, $zero, $zero   # nop
        add $t3,$zero, $v0        # store the result from $v0 in $t3
        lui $a0, 0x1000
        ori $a0, $a0, 0x1048      #load address for parity p4
        sw $v0 0($a0)             # store P4 in memory
        add $zero, $zero, $zero   # nop

        # Calculate p8 (Unvalidated 11)
        andi $t4, $t0, 0x7F0      # extract p1 parity bits
        add $s0, $zero, $t4       # set argument value for Parity_count
        addi $s1, $zero, 11     #counter for loop

        jal Parity_count          # counts the number of 1's
        add $zero, $zero, $zero   # nop
        add $zero, $zero, $zero   # nop
        add $t4,$zero, $v0        # store the result from $v0 in $t4
        lui $a0, 0x1000
        ori $a0, $a0, 0x104c      #load address for parity p8
        sw $v0 0($a0)             # store P8 in memory
        add $zero, $zero, $zero   # nop
        




########################Calculating Unvailed data Overall parity bits ########################################################################

# Build encoded Data

        add $t6, $zero, $zero      # stores combined value
        lui $a0, 0x1000           #load upper immediate address of raw 11_bit_extracted
        ori $a0, $a0, 0x1070      #load lower immediate address of raw 11_bit_extracted
        lw $s0, 0($a0)             # load value value into $t0
        add $zero, $zero, $zero   # nop
        add $a0, $zero, $t0        # $a0 = $t0
        

        #p1
        sll $t1, $t1, 1           # shift p1 by 1 place
        or $t6, $t6, $t1          # add it to combine using or
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
        #p2
        sll $t2, $t2, 2           # shift p2 by 2 place
        or $t6, $t6, $t2          # add it to combine using or

        #d1
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 0        # index to extract
        jal extract_bit           # branch to extra d1
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 3           # shift d1 by 3 place
        or $t6, $t6, $v0          # add it to combine using or

        #p3
        sll $t3, $t3, 4           # shift p3 by 4 place
        or $t6, $t6, $t3          # add it to combine using or

        #d2
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 1        # index to extract
        jal extract_bit           # branch to extra d2
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 5           # shift d2 by 5 place
        or $t6, $t6, $v0          # add it to combine using or

        #d3
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 2        # index to extract
        jal extract_bit           # branch to extra d3
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 6           # shift d3 by 6 place
        or $t6, $t6, $v0          # add it to combine using or

        #d4
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 3        # index to extract
        jal extract_bit           # branch to extra d4
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 7           # shift d4 by 7 place
        or $t6, $t6, $v0          # add it to combine using or

        #p4
        sll $t4, $t4, 8           # shift p3 by 4 place
        or $t6, $t6, $t4          # add it to combine using or

        #d5
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 4        # index to extract
        jal extract_bit           # branch to extra d5
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 9           # shift d5 by 9 place
        or $t6, $t6, $v0          # add it to combine using or

        #d6
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 5        # index to extract
        jal extract_bit           # branch to extra d6
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 10           # shift d6 by 10 place
        or $t6, $t6, $v0          # add it to combine using or

        #d7
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 6        # index to extract
        jal extract_bit           # branch to extra d7
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 11           # shift d7 by 11 place
        or $t6, $t6, $v0          # add it to combine using or

        #d8
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 7        # index to extract
        jal extract_bit           # branch to extra d8
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 12           # shift d8 by 12 place
        or $t6, $t6, $v0          # add it to combine using or

        #d9
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 8        # index to extract
        jal extract_bit           # branch to extra d9
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 13           # shift d9 by 13 place
        or $t6, $t6, $v0          # add it to combine using or

        #d10
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 9        # index to extract
        jal extract_bit           # branch to extra d10
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 14           # shift d10 by 14 place
        or $t6, $t6, $v0          # add it to combine using or

        #d11
        add $a0, $zero, $s0       # $a0 = $s0 (s0 stores cordword value)
        addi $a1, $zero, 10        # index to extract
        jal extract_bit           # branch to extra d11
        add $zero, $zero, $zero   # nop
        sll $v0, $v0, 15           # shift d11 by 15 place
        or $t6, $t6, $v0          # add it to combine using or

        lui $a1, 0x1000           #load upper immediate address full_16_bits
        ori $a1, $a1, 0x1060      #load lower immediate address full_16_bits
        sw $t6, 0($a1)

#Calculating Total Parity
        # Calculate p0
        add $t0, $zero, $t6       # copy in the 16 bits
        andi $t5, $t0, 0x7FFF      # extract p0 parity bits
        add $s0, $zero, $t5       # set argument value for Parity_count
        addi $s1, $zero, 15       #counter for loop 

        jal Parity_count          # counts the number of 1's
        add $zero, $zero, $zero   # nop
        add $zero, $zero, $zero   # nop
        add $t5,$zero, $v0        # store the result from $v0 in $t5
        lui $a0, 0x1000
        ori $a0, $a0, 0x1050      #load address for parity p5
        sw $t5 0($a0)             # store P5 in memory

# Combine Total Parity with final output
        #p1
        or $t6, $t6, $t5          # add it to combine using or
        #store result again
        lui $a1, 0x1000           #load upper immediate address full_16_bits
        ori $a1, $a1, 0x1060      #load lower immediate address full_16_bits
        sw $t6, 0($a1)

################## Create Hamming Code Sysdrome#####################

        lui $a3, 0x1000           # load immediate upper address for 4 bit hamming code
        ori $a3, $a3, 0x1100      # load immediate lower address for 4 bit hamming code
        lw $t6, 0($a3)            # store 4 bit hamming code in memory
        add $zero, $zero, $zero   #nop

        # xor p1
        lui $a0, 0x1000           # load immediate upper address for 4 bit hamming code
        ori $a0, $a0, 0x1040      # load immediate lower address for 4 bit hamming code
        lw $t5, 0($a0)            # store 4 bit hamming code in memory
        add $zero, $zero, $zero   #nop

        xor $t6, $t6, $t5 

        # xor p2
        lui $a0, 0x1000           # load immediate upper address for 4 bit hamming code
        ori $a0, $a0, 0x1044      # load immediate lower address for 4 bit hamming code
        lw $t5, 0($a0)            # store 4 bit hamming code in memory
        add $zero, $zero, $zero   #nop

        sll $t5, $t5 1
        xor $t6, $t6, $t5 

        # xor p4
        lui $a0, 0x1000           # load immediate upper address for 4 bit hamming code
        ori $a0, $a0, 0x1048      # load immediate lower address for 4 bit hamming code
        lw $t5, 0($a0)            # store 4 bit hamming code in memory
        add $zero, $zero, $zero   #nop

        sll $t5, $t5, 2
        xor $t6, $t6, $t5 

        # xor p8
        lui $a0, 0x1000           # load immediate upper address for 4 bit hamming code
        ori $a0, $a0, 0x104c      # load immediate lower address for 4 bit hamming code
        lw $t5, 0($a0)            # store 4 bit hamming code in memory
        add $zero, $zero, $zero   #nop

        sll $t5, $t5 3
        xor $t6, $t6, $t5 

        sw $t6 0($a3)

        

########################################## Print Outputs Data ########################################################################
                  

        jal New_Line       # Adds a new line
        add $zero, $zero, $zero   # nop
        jal New_Line       # Adds a new line
        add $zero, $zero, $zero   # nop
        #print p0 
        lui $a0, 0x1000
        ori $a0, $a0, 0x0270
        #li $v0, 4             # prints the string 
        lui $v0, 0x0000
        ori $v0, $v0, 0x0004
        syscall

        # Unvaildated 11 bit extraction
        lui, $a0, 0x1000         # load the address of the 11 bit message
        ori $a0, $a0, 0x1070     # load lower 16 bit of address
        addi $t1, $zero, 11        # length of string
        jal print
        add $zero, $zero, $zero   # nop

       
      jal New_Line       # Adds a new line
      add $zero, $zero, $zero   # nop

      #print p8  
      lui $a0, 0x1000
      ori $a0, $a0, 0x0200
      #li $v0, 4             # prints the string 
      lui $v0, 0x0000
      ori $v0, $v0, 0x0004
      syscall

           # address for p8 
      lui $a0, 0x1000           # upper immediate of address
      ori $a0, $a0, 0x104c      # lowe immediate of address
      addi $t1, $zero, 1        # length of string
      jal print
      add $zero, $zero, $zero   # nop

      jal New_Line       # Adds a new line
      add $zero, $zero, $zero   # nop

      #print p4  
      lui $a0, 0x1000
      ori $a0, $a0, 0x0210
      #li $v0, 4             # prints the string 
      lui $v0, 0x0000
      ori $v0, $v0, 0x0004
      syscall

           # address for p4 
      lui $a0, 0x1000           # upper immediate of address
      ori $a0, $a0, 0x1048      # lowe immediate of address
      addi $t1, $zero, 1        # length of string
      jal print
      add $zero, $zero, $zero   # nop

      jal New_Line       # Adds a new line
      add $zero, $zero, $zero   # nop

      #print p2  
      lui $a0, 0x1000
      ori $a0, $a0, 0x0220
      #li $v0, 4             # prints the string 
      lui $v0, 0x0000
      ori $v0, $v0, 0x0004
      syscall

           # address for p2
      lui $a0, 0x1000           # upper immediate of address
      ori $a0, $a0, 0x1044      # lowe immediate of address
      addi $t1, $zero, 1        # length of string
      jal print
      add $zero, $zero, $zero   # nop

      jal New_Line       # Adds a new line
      add $zero, $zero, $zero   # nop

      #print p1  
      lui $a0, 0x1000
      ori $a0, $a0, 0x0230
      #li $v0, 4             # prints the string 
      lui $v0, 0x0000
      ori $v0, $v0, 0x0004
      syscall

           # address for p1 
      lui $a0, 0x1000           # upper immediate of address
      ori $a0, $a0, 0x1040      # lowe immediate of address
      addi $t1, $zero, 1        # length of string
      jal print
      add $zero, $zero, $zero   # nop

      jal New_Line       # Adds a new line
      add $zero, $zero, $zero   # nop
      #print p0 
      lui $a0, 0x1000
      ori $a0, $a0, 0x0240
      #li $v0, 4             # prints the string 
      lui $v0, 0x0000
      ori $v0, $v0, 0x0004
      syscall

           # address for p0 
      lui $a0, 0x1000           # upper immediate of address
      ori $a0, $a0, 0x1050      # lowe immediate of address
      addi $t1, $zero, 1        # length of string
      jal print
      add $zero, $zero, $zero   # nop

# Promp hamming code syndrom
      jal New_Line       # Adds a new line
      add $zero, $zero, $zero   # nop
      #print p0 
      lui $a0, 0x1000
      ori $a0, $a0, 0x00d0
      #li $v0, 4             # prints the string 
      lui $v0, 0x0000
      ori $v0, $v0, 0x0004
      syscall

        # Print Hamming Code symdrome
      lui $a0, 0x1000           # upper immediate of address
      ori $a0, $a0, 0x1100      # lowe immediate of address
      addi $t1, $zero, 4        # length of string
      jal print
      add $zero, $zero, $zero   # nop

        jal Syndrome

        jal New_Line       # Adds a new line
        add $zero, $zero, $zero   # nop
        jal New_Line       # Adds a new line
        add $zero, $zero, $zero   # nop


      
        j main
        add $zero, $zero, $zero   # nop



#################################3
        
Syndrome:
        add $t9, $zero, $ra
        lui $a0, 0x1000           # load immediate upper address for 4 bit hamming code
        ori $a0, $a0, 0x1100      # load immediate lower address for 4 bit hamming code
        lw $t6, 0($a0)            # store 4 bit hamming code in memory
        add $t8, $zero, $t6
        add $zero, $zero, $zero   # nop

        lui $a0, 0x1000
        ori $a0, 0x1050
        lw $t1, 0($a0)            #  unvalid total parity bits p0 prime

        lui $a0, 0x1000
        ori $a0, $a0, 0x1020
        lw $t4, 0($a0)            #  unvalid 11 bit data 

        #p0 (16 bit encoded)
        add $a0, $zero, $t4      # $a0 = $t0 (a0 stores code value)
        addi $a1, $zero, 0        # index to extract
        jal extract_bit_d           # branch to extra p0
        add $zero, $zero, $zero   # nop
        or $t2, $zero, $s1          # stores encode data p0

        xor $t1, $t1, $t2       # xor of both parity bits
        

 ###########################print  Pass or Fail ########################
        beq $t1, $zero, print_true # if p0 equal zero branch
        add $zero, $zero, $zero   # nop 
                jal New_Line              # Adds a new line
                add $zero, $zero, $zero   # nop
        # print false
                lui $a0, 0x1000
                ori $a0, $a0, 0x0320
                #li $v0, 4                # prints the string 
                lui $v0, 0x0000
                ori $v0, $v0, 0x0004
                syscall
                

                j continue
                add $zero, $zero, $zero   # nop

        print_true:    

               jal New_Line       # Adds a new line
                add $zero, $zero, $zero   # nop
        # print true
                lui $a0, 0x1000
                ori $a0, $a0, 0x02F0
                #li $v0, 4               # prints the string 
                lui $v0, 0x0000
                ori $v0, $v0, 0x0004
                syscall

        continue:
                
######################################################################################################
        lui $a0, 0x1000           # load immediate upper address for 4 bit hamming code
        ori $a0, $a0, 0x1100      # load immediate lower address for 4 bit hamming code
        lw $t6, 0($a0)            # store 4 bit hamming code in memory
        add $zero, $zero, $zero   # nop
        add $t8, $zero, $t6
        

        or $t8, $t1, $t8
        beq $t8, $zero, no_error
        add $zero, $zero, $zero   # nop

        #lui $a3, 0x1000
        #ori $a3, $a3, 0x1050
        
        add $t5, $zero, $t1             # represent encode data error
        bne $t6, $zero, add_error       # if hamming if not equal to zero add error
        add $zero, $zero, $zero   # nop

        j check_error
        add $zero, $zero, $zero   # nop

        add_error: 
                addi $t5, $t5, 2

        check_error:
                addi $s4, $zero, 3

        beq $t5, $s4, multi_error   # if t5 equal 3 jump to multi_error
        add $zero, $zero, $zero   # nop

        edit_bit:

                lui $a3, 0x1000
                ori $a3, $a3, 0x1020
                lw $s0, 0($a3)
                
                add $a1, $zero, $t6
                jal replace_bit
                add $zero, $zero, $zero   # nop
                sw $s0, 0($a3)


                lui $a3, 0x1000
                ori $a3, $a3, 0x1080      # load address for correct/fixed code word
                sw $s0, 0($a3)            # Store Corrected correct/fixed code word


                lui $a1, 0x1000
                ori $a1, $a1 0x1090        # output address
                sw $s0, 0($a1)             # store value in output

                jal New_Line       # Adds a new line
                add $zero, $zero, $zero   # nop
        #print decoded message 
                lui $a0, 0x1000
                ori $a0, $a0, 0x0290
                #li $v0, 4             # prints the string 
                lui $v0, 0x0000
                ori $v0, $v0, 0x0004
                syscall
                

        # print result
                lui $a0, 0x1000           # upper immediate of address
                ori $a0, $a0, 0x1090      # lowe immediate of address
                addi $t1, $zero, 11        # length of string
                jal print
                add $zero, $zero, $zero   # nop

                j Exit_syn
                add $zero, $zero, $zero   # nop

        multi_error:
                add $s4, $zero, $zero
                lui $s4, 0xFFFF
                ori $s4, $s0, 0xFFFF
                lui $a0, 0x1000
                ori $a0, $a0, 0x1070      # load address for correct/fixed code word
                sw $s4, 0($a0)            # Store Corrected correct/fixed code word
                
                lui $a1, 0x1000
                ori $a1, $a1 0x1090        # output address
                sw $s4, 0($a0)             # store value in output

                jal New_Line       # Adds a new line
                add $zero, $zero, $zero   # nop
        #print error 
                lui $a0, 0x1000
                ori $a0, $a0, 0x02B0
                #li $v0, 4             # prints the string 
                lui $v0, 0x0000
                ori $v0, $v0, 0x0004
                syscall
                # address for p0 

                # print -1

                addi $a0, $zero, -1
                addi $v0, $zero, 1
                syscall

                add $zero, $zero, $zero   # nop
                j Exit_syn
                 
        no_error:
                lui $a1, 0x1000
                ori $a1, $a1 0x1080       # load address for correct/fixed code word
                sw $t4, 0($a1)            # Store Corrected correct/fixed code word

                lui $a1, 0x1000
                ori $a1, $a1 0x1090       # output address
                sw $t4, 0($a1)             # store value in output

                jal New_Line       # Adds a new line
                add $zero, $zero, $zero   # nop
        #print decode data 
                lui $a0, 0x1000
                ori $a0, $a0, 0x0290
                #li $v0, 4             # prints the string 
                lui $v0, 0x0000
                ori $v0, $v0, 0x0004
                syscall

        # address for result 
                lui $a0, 0x1000           # upper immediate of address
                ori $a0, $a0, 0x1090      # lowe immediate of address
                addi $t1, $zero, 11        # length of string
                jal print
                add $zero, $zero, $zero   # nop

                j Exit_syn
                add $zero, $zero, $zero   # nop

             Exit_syn:   
                ##add $ra, $zero, $t9
                jr $t9
                add $zero, $zero, $zero   # nop


        replace_bit:
        sll  $t0, $s0, $a1        # shift $s0 left by (a1)th bits, where a1th is the bit position to flip
        addi $t1, $zero, 1             # load the value (a1)th into $t1
        sll  $t1, $t1, $a1        # shift $t1 left by a1th bits, so it has a 1 in the nth bit position
        xor  $s0, $s0, $t1      # use the xor operation to flip the nth bit of $s0           

        #return
        jr $ra                  # return from the function
        add $zero, $zero, $zero   # nop




####################
        ##
        ##
        ##
        ##
        ##
        ##
        ##


# Function/Module Name:
# Summary of Purpose:
# Input/Stored Value Requirements:
# Values Stored/Returned:
Terminate:
      jal New_Line       # Adds a new line
      add $zero, $zero, $zero   # nop
      jal New_Line       # Adds a new line
      add $zero, $zero, $zero   # nop
      jal New_Line       # Adds a new line
      add $zero, $zero, $zero   # nop
      #print p0 
      lui $a0, 0x1000
      ori $a0, $a0, 0x00b0
      #li $v0, 4             # prints the string 
      lui $v0, 0x0000
      ori $v0, $v0, 0x0004
      syscall

       # Exit Program
       lui $v0, 0x0000
       ori $v0, $v0 0x000a
       syscall