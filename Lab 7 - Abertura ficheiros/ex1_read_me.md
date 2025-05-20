# 📘 Leitura de Ficheiros em Assembly RISC-V

## 🧭 Como alterar o caminho do ficheiro

No segmento `.data`, podes modificar o caminho do ficheiro que será lido.

### ✅ Caminho absoluto

```asm
file_input: .string "C:/Users/Joao/Desktop/exemplo.txt"
```

### ✅ Caminho relativo (ficheiro na mesma pasta que o `.asm`)

```asm
file_input: .string "./mensagem.txt"
```

> ⚠️ Usa **barras normais `/`** mesmo em Windows. Evita `\`, pois o assembler interpreta como sequência de escape inválida.

---

## 📦 Segmento `.data`

```asm
buffer_input:  .zero 14
```
Reserva 14 bytes de memória para guardar os dados lidos do ficheiro.

```asm
null: .string ""
```
String vazia (não utilizada neste código, mas pode servir como terminador noutros contextos).

```asm
file_input: .string "C:/Users/Duarte/Documents/GitHub/IAC_2025/Lab 7 - Abertura ficheiros/mensagem.txt"
```
Caminho para o ficheiro que será lido.

---

## 🔧 Código Assembly Completo (com explicações)

```asm
.text

main:
    # Carregar argumentos para a função read_file
    la  a0, file_input       # a0 = endereço do nome do ficheiro
    la  a1, buffer_input     # a1 = endereço do buffer onde guardar os dados
    li  a2, 14               # a2 = número de bytes a ler
    jal ra, read_file        # chama a função read_file
    
    # Imprimir o conteúdo lido
    la a0, buffer_input
    li a7, 4                 # syscall: PrintString
    ecall

    # Terminar programa
    li a7, 10                # syscall: exit
    ecall


######################################################################
# Função: read_file(char* filename, byte* buffer, int length)
# Entradas:
#   a0: ponteiro para string com nome do ficheiro
#   a1: buffer destino
#   a2: número de bytes a ler
# Saídas:
#   a0: número de bytes lidos
# Exceções:
#   - Código 41 se erro ao abrir ficheiro
#   - Código 42 se o número de bytes a ler for <= 0
######################################################################

read_file:
    # Guardar argumentos em temporários
    mv  t0, a0
    mv  t1, a1
    mv  t2, a2
    
    li  a0, 42
    ble a2, x0, exit_with_error   # se length <= 0, erro 42

    # Abrir ficheiro: open(filename, 0, 0)
    mv a0, t0
    li a1, 0                 # flags = 0 (read-only)
    li a2, 0                 # mode = 0
    li a7, 1024              # syscall: open
    ecall
    mv t3, a0                # t3 = file descriptor

    # Verificar erro na abertura
    li  a0, 41
    li  t4, -1
    beq t3, t4, exit_with_error   # se fd == -1, erro 41

    # Ler ficheiro: read(fd, buffer, length)
    mv a0, t3                # fd
    mv a1, t1                # buffer
    mv a2, t2                # número de bytes
    li a7, 63                # syscall: read
    ecall
    mv t3, a0                # guardar número de bytes lidos

    # Verificar erro na leitura
    li  a0, 41
    li  t4, -1
    beq t3, t4, exit_with_error   # erro 41 se leitura falhar

    jr ra                    # retornar ao main

# Sair com erro
exit_with_error:
  li a7, 93            # syscall: exit with code
  ecall
```

---

## 🧠 Tabela de Memória: Antes e Depois da Execução

### 📥 Início da memória (`0x10000000`) — antes do programa

| Endereço       | Conteúdo   |
|----------------|------------|
| `0x10000000`   | `lleH`     |
| `0x10000004`   | `oW o`     |
| `0x10000008`   | `dlr`      |
| `0x1000000c`   | `C!!`      |

### 📤 Fim do carregamento (`0x1000005c`) — após ler o ficheiro

| Endereço       | Conteúdo   |
|----------------|------------|
| `0x10000048`   | `if a`     |
| `0x1000004c`   | `iehc`     |
| `0x10000050`   | `/sor`     |
| `0x10000054`   | `snem`     |
| `0x10000058`   | `mega`     |
| `0x1000005c`   | `txt.`     |

🧩 Nota: Os dados foram carregados no buffer `buffer_input`, que começa numa dessas posições — o conteúdo representa uma string invertida do tipo:

```txt
.txtamensros
```

---

## ✅ Resumo

- O código abre um ficheiro, lê 14 bytes e imprime o conteúdo.
- Implementa **verificação de erros** (ficheiro não encontrado, tamanho inválido).
- Pode ser adaptado facilmente para outros ficheiros ou tamanhos.
- Usa syscalls padrão do sistema operativo compatível com RISC-V.

---
