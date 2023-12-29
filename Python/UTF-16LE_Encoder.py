def utf16le_encode(text):
    """
    Encode the provided text to UTF-16LE (Little Endian) format.
    """
    try:
        # Python's 'utf-16le' encoding omits the Byte Order Mark (BOM)
        return text.encode('utf-16le')
    except Exception as e:
        return str(e)

# Example usage
text = "dir /a"
encoded_text = utf16le_encode(text)

# The encoded text will be in bytes format, you might want to print it as a hex representation
print(encoded_text.hex())
