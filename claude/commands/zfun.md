Add a new zsh function to ~/.zshrc with proper organization and description.

Usage: /zfun [function-description]

Instructions for Claude:

1. Read the user's ~/.zshrc file to understand its current structure and function organization
2. Identify the existing function groupings (sections marked with `# ----Section----#` patterns)
3. Note the zfun() function's func_desc array structure for function descriptions
4. Based on the user's request, create a new zsh function that:
   - Accomplishes what the user asked for
   - Follows the coding style of existing functions
   - Uses appropriate error handling and user feedback (emojis, echo statements)
   - Fits logically into one of the existing sections

5. Present the function to the user with:
   - The complete function code
   - The description line to add to func_desc array in format: `[function_name]="Brief description"`

6. Wait for user approval

7. If approved, edit ~/.zshrc to:
   - Add the function in the appropriate section (maintaining spacing and formatting)
   - Add the description to the func_desc array in the zfun() function, in the correct section
