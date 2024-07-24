import sys

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
        regm = format(int(parts[1][1]), '03b')
        reg1 = format(int(parts[2][1]), '03b')
        
        return f'100{regm}{reg1}0000000'
    
    elif opcode == 'BN':  # Branch if Negative
        regm = format(int(parts[1][1]), '03b')
        reg1 = format(int(parts[2][1]), '03b')
        
        return f'101{regm}{reg1}0000000'
    
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

def assemble_file(input_file, output_file):
    with open(input_file, 'r') as infile:
        lines = infile.readlines()
    
    machine_code = []
    for line in lines:
        line = line.strip()
        if line:
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