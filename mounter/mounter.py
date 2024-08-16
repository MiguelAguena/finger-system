import sys
import re

def assemble_instruction(instruction):
    parts = instruction.split()
    opcode = parts[0].upper()
    
    if opcode == 'NOP':
        return '0000000000000000'
    
    elif opcode in ['ADD', 'SUB', 'AND', 'OR', 'XOR']:  # ALU Instructions
        regd = format(int(parts[1][1]), '03b')
        reg2 = format(int(parts[2][1]), '03b')
        reg1 = format(int(parts[3][1]), '03b')
        
        alu = {
            'ADD': '00',
            'SUB': '01',
            'AND': '10',
            'OR':  '11',
            'XOR': '12'
        }[opcode]
        
        return f'001{regd}{reg2}{reg1}{alu}00'
    
    elif opcode == 'LI':  # Immediate Load
        regd = format(int(parts[1][1]), '03b')
        imm = format(int(parts[2]), '010b')
        
        return f'010{regd}{imm}'
    
    elif opcode in ['ADDI', 'SUBI', 'ANDI', 'ORI', 'XORI']:  # Immediate ALU Instructions
        regd = format(int(parts[1][1]), '03b')
        reg1 = format(int(parts[2][1]), '03b')
        imm = format(int(parts[3]), '05b')
        
        alu = {
            'ADDI': '00',
            'SUBI': '01',
            'ANDI': '10',
            'ORI':  '11',
            'XORI': '12'
        }[opcode]
        
        return f'011{regd}{reg1}{alu}{imm}'
    
    elif opcode == 'BZ':  # Branch if Zero
        regd = format(int(parts[1][1]), '03b')
        reg1 = format(int(parts[2][1]), '03b')
        
        return f'100{regd}{reg1}0000000'
    
    elif opcode == 'BN':  # Branch if Negative
        regd = format(int(parts[1][1]), '03b')
        reg1 = format(int(parts[2][1]), '03b')
        
        return f'101{regd}{reg1}0000000'
    
    elif opcode == 'LD':  # Load
        regd = format(int(parts[1][1]), '03b')
        reg1 = format(int(parts[2][1]), '03b')
        
        return f'110{regd}{reg1}0000000'
    
    elif opcode == 'ST':  # Store
        regm = format(int(parts[1][1]), '03b')
        reg1 = format(int(parts[2][1]), '03b')
        
        return f'111{regm}{reg1}0000000'
    
    else:
        raise ValueError(f'Unknown instruction: {instruction}')

def process_labels_and_branches(lines):
    label_addresses = {}
    branch_adresses = []
    address = 0
    routine = ''
    routine_branches = {}

    # First pass: Record label addresses
    for line in lines:
        line = line.strip()
        if line and not line.startswith(';'):
            if ':' in line:
                label = line.split(':')[0].strip()
                label_addresses[label] = address
                routine = label
                routine_branches[routine] = []
            elif line.startswith('B '):
                branch_adresses.append(address)
                branch_label = line.split('B ')[1].split(';')[0].replace(" ", "")
                routine_branches[routine].append(branch_label)
                address +=1
            else:
                address += 1
    # Segundo passe: Identificar o tipo de acesso para cada subrotina
    access_type = {}
    address = 0
    for line in lines:
        if line and not line.startswith(';'):
            if line.startswith('B '):
                # Identificar o label de destino do desvio
                parts = line.split()
                label = parts[1]
                if label in label_addresses:
                    # O primeiro acesso a essa subrotina é por desvio
                    access_type[label] = 'branch'    
    # Verificar acessos sequenciais
    for label, label_address in label_addresses.items():
        if label not in access_type:
            access_type[label] = 'sequential'

    print(f'Acces type: {access_type}')
    print(f'Routine branches: {routine_branches}')
    print(f'Label addresses: {label_addresses}')
    print(f'Branch addresses: {branch_adresses}')

    processed_lines = []
    address = 0
    new_lines = []
    
    # Second pass: Replace branches and process instructions
    current_routine = ''
    for line in lines:
        line = line.strip()
        if line and not line.startswith(';'):
            if ':' in line:
                label = line.split(':')[0].strip()
                current_routine = label
                # Labels are not processed here
                new_lines.append("ST R4 R5")
                new_lines.append("SUBI R5 R5 2")
                new_lines.append(line)
                new_lines.append("ADDI R5 R5 2")
                new_lines.append("LD R4 R5")
            else:
                parts = line.split()
                opcode = parts[0].upper()
                
                if opcode == 'B':
                    label = parts[1]
                    label_address = label_addresses[label]
                    branch_address = address

                    print(f'Label: {label}')
                    print(f'Label address: {label_address}')
                    print(f'Label addresses: {label_addresses}')
                    print(f'Branch address: {branch_address}')

                    # Check for following branches and recalculate label address
                    # next_branches = [address for address in branch_adresses if address > branch_address]
                    # previous_routines = [address for routine, address in label_addresses.items() if address < branch_address]
                    # next_routines = len(label_addresses) - previous_routines - 1
                    
                    # if len(next_branches) > 0:
                    #     offset = (len(next_branches) + 1)*3 + 2 + (len(label_addresses) -1)*4
                    #     # qtde de rotinas sem ser a  
                    # elif len(previous_routines) > 0:
                    #     # sem branches depois
                    #     if label == current_routine: 
                    #         # branch para a propria rotina 
                    #         offset = (len(previous_routines)-1)*4 + 2
                    #     else: 
                    #         # branch para uma rotina diferente
                    #         offset = (len(next_branches) + 1)


                    # if len(next_branches) > 0 or len(previous_routines) > 0:

                    #     offset = (len(next_branches) + 1)*3 + 2 + (len(previous_routines)*4)
                    #     print(f'Next address: {next_branches}')
                    #     print(f'Offset: {offset}')
                    #     label_address += offset
                    #     label_addresses[label] = label_address
                    #     print(f'Label adress atualizado: {label_address}')
                    
                    # Insert the branch code
                    new_lines.append(f'ST R4 R5')   # Store R4 on stack
                    new_lines.append(f'SUBI R5 R5 2')  # Decrement stack pointer
                    new_lines.append(f'LI R4 {label}')  # Load label address into R4
                    new_lines.append(f'BZ R4 R0')  # Branch to address in R4
                    
                    address += 1
                    
                else:
                    # Normal instruction processing
                    new_lines.append(line)
                    address += 1
    
    # Adjust subroutines to include restore instructions
    final_lines = []
    address = 0
    for line in new_lines:
        line = line.strip()
        if line and not line.startswith(';'):
            parts = line.split()

            pattern = r'^LI R4 \w+$'

            if re.match(pattern, line):
                print(f'Deu match: {line}')
                label_branch = parts[2]
                address = 0
                for line in new_lines:
                    line = line.strip()
                    if line and not line.startswith(';'):
                        #print(f'Linhah: {line}')
                        if ':' in line:
                            label = line.replace(":", "")
                            if label == label_branch:
                                print('-----')
                                print(label)
                                print(address)
                                label_address = address
                        else:
                            address +=1
                
                line = f'LI R4 {label_address}'
                print(f'Nova linha: {line}')

            # if len(parts) > 1 and parts[1].endswith(':'):
            #     label = parts[0]
            #     final_lines.append(line)
            #     if label in label_addresses:
            #         # Add restore instructions at the start of the subroutine
            #         final_lines.append(f'ADDI R5 R5 2')  # Increment stack pointer
            #         final_lines.append(f'LD R4 R5')  # Restore R4 from stack
            #         address += 1
            # else:
            final_lines.append(line)
            address += 1

    return final_lines, label_addresses

def assemble_file(input_file, output_file):
    with open(input_file, 'r') as infile:
        lines = infile.readlines()
    
    processed_lines, label_addresses = process_labels_and_branches(lines)
    
    machine_code = []
    for line in processed_lines:
        line = line.strip()
        if line and not line.startswith(';'):
            try:
                machine_code.append(assemble_instruction(line))
            except ValueError as e:
                print(f"Error assembling line '{line}': {e}")
    
    with open(output_file, 'w') as outfile:
        for code in machine_code:
            outfile.write(code + '\n')

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python assembler.py <input_file.s> <output_file.txt>")
    else:
        input_file = sys.argv[1]
        output_file = sys.argv[2]
        assemble_file(input_file, output_file)
        print(f"Assembly code has been assembled and written to {output_file}")