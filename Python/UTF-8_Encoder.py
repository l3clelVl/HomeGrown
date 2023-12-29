def utf8_encode(text):
    """
    Encode the provided text to UTF-8 format.
    """
    try:
        return text.encode('utf-8')
    except Exception as e:
        return str(e)

# Example usage
text = "dir /a"
encoded_text = utf8_encode(text)

# The encoded text will be in bytes format, you might want to print it as a hex representation
print(encoded_text.hex())
