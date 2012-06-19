Installation
============

In order to make this setup functional on any Linux computer, download this repository and execute the following commands:

```bash
# Rename to .vim
mv dotfiles ~/.vim

# Make links to the configuration files from your home folder
echo 'source ~/.vim/configuration.vim' > ~/.vimrc
ln -s ~/.vim/foreign/zsh.config ~/.zshrc

# Switch to zsh instead of bash
chsh -s zsh

# Decompress Java resources
cd ~/.vim/resources/java
tar -xvf api.tar.gz
cd

# Install Vundle
git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle

# Create backup and swap file directories for Vim
mkdir -p ~/.vim/tmp/backup
```

After that, make sure that when your .vimrc is being loaded, the HOME environment variable is defined, because vim uses it to find other files.

Next, if you have Java projects you want to have indexed and tagged, edit the ~/.vim/indexer.list file. 
The format should be rather self explanatory, except for the minor note that '**' means 'recursively' when applied to directories.

If you prefer a different color scheme, replace ~/.vim/colorscheme.vim with one of your own choice.

Note that in order to use all features, you have to have firefox and ant installed.
Similarly, the Android SDK must be installed in ~/.android.

Changes made to projects should be done in current-projects.vim and indexer.list only.

List of Features (Aimed at Java and Android Development)
=======================================================
* Code Folding:
    * By default, folds anything above 5 lines
    * "za" to toggle whether or not it's folded
    * "zR" to unfold everything
    * "zA" to toggle whether or not a whole series of folds are open/closed
    * ":e %" to close all the folds
* Autocompletion and Refactoring:
    * Ctrl-X Ctrl-U to start smart, context-aware autocompletion
    * Ctrl-U to go down the list (or Ctrl-N)
    * Ctrl-P to go up the list
    * Ctrl-N (no Ctrl-X) to autocomplete based on things in this file - good for things like strings or variable names
    * Ctrl - P - same as Ctrl-N, only searches in the other direction from the cursor
    * "\ai" - imports whatever class your cursor is on
    * "\jt" - surrounds any code you have highlighted with try/catch
    * "\js" - sort import statements
    * "\jg" - generate getter/setter
    * "\jc" - generate class constructor which will take all the variables the class has in it
    * May/or may not work: "\fr", "\ft" - automatically fix the current error with a throws statement or a try/catch
    * Other refactorings/creation wizards available from Gvim menu
* Building/launching your application:
    * If you're using maven (you aren't), press Shift-F5
    * If you're using ant (you are, for android), press &lt;F5&gt; to build app, install, and run on phone
    * If compile fails, it will take you to the error immediately
    * If there's more than one error, press &lt;F6&gt; to go to the next one
    * Press shift &lt;F6&gt; to go to the previous error
    * Press &lt;F7&gt; to look at logcat output - only display things with message "Swade" (show all debug output)
    * Press Shift &lt;F7&gt; to look at logcat output - only display things with message "Swade" (show error or fatal error ONLY)
* Navigation:
    * h, j, k, l to navigate instead of arrow keys
    * H, J, K, L to navigate 10x faster (fast scrolling)
    * If you're lame and using Gvim, you can use a mouse
    * Ctrl ] to jump to the declaration your cursor is on
    * Ctrl \ to jump BACK to where you used Ctrl ] the previous time
    * Note: Ctrl ] and Ctrl \ form a stack, so you can keep jumping deeper and then unwind the stack
    * Ctrl - e to go to end of line, Ctrl - a to go to start of line, Ctrl k to delete until end of line
    * gg to go to start of file
    * G to go to end of file
    * / to search forward
    * ? to search backward
* Other random nice things:
    * type "for", "while", "if", etc and press tab, and it will autocomplete for you. Press tab to move on once you're done filling in the conditions.
    * It inserts closing ) and ] and } for you, and adds new lines and indents when needed (for new {} blocks)
    * Everything else that Vim can do!
    * Press Ctrl-Shift-O over a class name or import statement to open the Javadoc for it in Firefox
