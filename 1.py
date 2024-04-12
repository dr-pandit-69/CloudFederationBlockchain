from mnemonic import Mnemonic

def generate_mnemonic(num_words):
    strength = {
        12: 128,
        15: 160,
        18: 192,
        21: 224,
        24: 256
    }

    mnemo = Mnemonic("english")  
    words = []
    
    
    nearest = min(strength.keys(), key=lambda x: x - num_words if x >= num_words else float('inf'))
    

    for i in range(num_words // nearest):
        words.append(mnemo.generate(strength[nearest]))

    return ' '.join(words)


num_words = 200
mnemonic = generate_mnemonic(num_words)
print("New Mnemonic:", len(mnemonic.split(" ")))
