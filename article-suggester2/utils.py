
def get_yes_no(text):
    selection = ''
    while selection not in ['y', 'n']:
        selection = input(f'{text}')
    return selection == 'y'
