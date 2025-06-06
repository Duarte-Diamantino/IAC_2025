.data

buffer_input:  .zero 14
null:          .string ""

file_input:     .string "C:/Users/Duarte/Documents/GitHub/IAC_2025/Lab 7 - Abertura ficheiros/mensagem.txt"

.text

main:
    # Read both input files
    # read the image inputs

    la  a0, file_input       # a0 = pointer to filename
    la  a1, buffer_input     # a1 = pointer to buffer
    li  a2, 14               # a2 = number of bytes to read
    jal ra, read_file        # call read_file
    
   
    la a0, buffer_input
    li a7, 4                 # PrintString call
    ecall

    # Exit program
    li a7, 10                # syscall: exit
    ecall


######################################################################
# Function: read_file(char* filename, byte* buffer, int length)
# Input:
#   a0: pointer to null-terminated filename string
#   a1: destination buffer
#   a2: number of bytes to read
# Output:
#   a0: number of bytes read (return value from syscall)
# Exceptions:
#   - Error code 41 if error in the file descriptor
#   - Error code 42 If the length of the bytes to read is less than 1
######################################################################

read_file:

    # Verify the length exception
    mv  t0, a0
    mv  t1, a1
    mv  t2, a2
    
    li  a0, 42                    #
    ble a2, x0, exit_with_error   # if a5 <= 0, return error 42

    # Open the file: open(filename, 0, 0)
    # a0 = filename
    mv a0, t0
    li a1, 0                 # flags = 0 (read-only)
    li a2, 0                 # mode = 0
    li a7, 1024             
    # syscall: open
    ecall
    mv t3, a0                # t0 = file descriptor

    # Verify the file description error exception
    li  a0, 41
    li  t4, -1
    beq t3, t4, exit_with_error   # if a0 (fd) == -1, return error 41
    
        
    # Read the file: read(fd, buffer, length)
    mv a0, t3                # a0 = fd
    mv a1, t1                # a1 = buffer
    mv a2, t2                # a2 = number of bytes
    
    li a7, 63                # syscall: read
    ecall
    mv t3, a0                # t0 = file descriptor
   
    li  a0, 41
    li  t4, -1
    beq t3, t4, exit_with_error   # if a0 (fd) == -1, return error 41
    
    jr ra                    # Return to the caller

# Exits the program with an error 
# Arguments: 
# a0 (int) is the error code 
# You need to load a0 the error to a0 before to jump here
exit_with_error:
  li a7, 93            # Exi system call
  ecall                # Terminate program

        