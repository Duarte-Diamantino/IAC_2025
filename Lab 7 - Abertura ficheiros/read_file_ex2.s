.data

buffer_input_int:  .zero 3136
buffer_input_byte: .zero 796
file_input:        .string "C:/Users/Duarte/Downloads/classifier-files/classifier-files/input-images/ascii-pgm/output0.pgm"

.text

main:
    # Read both input files
    # read the image inputs

    la  a0, file_input        # a0 = pointer to filename
    la  a1, buffer_input_byte # a1 = pointer to buffer
    li  a2, 796               # a2 = number of bytes to read
    jal ra, read_file         # call read_file
    
    la  a0, buffer_input_byte
    la  a1, buffer_input_int  
    li  a2, 784	       # 28 x 28
    li  a3, 12                # define here the header size  
    jal ra, cast_array_to_int    
    
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
    blt a5, x0, exit_with_error   # if a5 <= 0, return error 42

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


######################################################################
# Function: cast_array_to_int(uint8_t* input, int* output, int length)
#
# Description:
#   Converts an array of `length` bytes starting from offset 12 in the
#   input buffer into an array of 32-bit integers (one byte per int).
#
# Input:
#   a0: pointer to the input byte buffer (uint8_t*)
#   a1: pointer to the output int buffer (int*)
#   a2: number of bytes to convert (int)
#   a3: header size
#
# Output:
#   output[i] = (int) input[i + N], for i in 0..length-1
#
# Notes:
# Clobbers:
#   t0, t1, t3, t4
#
# Return:
#   Returns to caller with `jr ra`
######################################################################

cast_array_to_int:
  li t1, 0 
  add a0, a0, a3     # Corrige: move o ponteiro de entrada para o byte 12

loop_cast:    
  add  t3, t1, a0     # t3 = a0 + t1
  lb   t0, 0(t3)      # t0 = *(a0 + t1)

  slli t4, t1, 2      # t4 = t1 * 4 (índice no array de inteiros)
  add  t3, t4, a1     # t3 = a1 + t4

  sw   t0, 0(t3)      # salva o byte como inteiro no array de saída

  addi t1, t1, 1
  blt  t1, a2, loop_cast
  
  jr ra

