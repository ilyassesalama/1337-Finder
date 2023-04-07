# 1337 Finder
This tiny project was made to practice the basic stuff we've learned in Born2beroot project at 1337 school. It was created using Bash, and it can be executed only in the school's iMacs since it's not linked to 42 API, but imagine if we could do that? Crazy.


### The benefits of the script?
When you choose someone to evaluate your project, the intranet hides the student's contact information after 10 minutes, then you will not be able to see them anymore to call them in case they're missing. So, the main issue this script solves is to get students' contact information with some perks as shown in the screenshow below.

<img src="https://user-images.githubusercontent.com/46769766/230552858-bcc3eb76-998a-4fed-ae32-8c4aa915b907.png" width="500">


### How to run the script?
You don't have to clone the repository, just execute the following command in your terminal to run the script directly from the repository:

```bash
bash <(curl -s https://raw.githubusercontent.com/ilyassesalama/1337-Finder/main/1337-Finder.sh)
```
Afterwards, the script will automatically add a new alias called `finder`, it will help simplify executing the script in the future by simply typing `finder LOGIN` in your terminal. `LOGIN` is supposed to be the student's school's login.
However, the `finder` alias will only work after restarting your terminal or by running this command `source ~/.bashrc`, or `source ~/.zshrc` depending on the shell you're using.

### Contributions?
I welcome contributions, the script task is simple but if you wish to improve the code then why not. I never had any experience in Bash before, so yeah.

### Warning
Please don't annoy other students using the information provided by this script. Use it only as it is supposed to be used, not to look for girls' numbers.
