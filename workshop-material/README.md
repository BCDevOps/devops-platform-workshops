# Markdown Formatting
A single markdown file is used for each section. 2 blank spaces indicates a new slide vertically, 
while 3 indicates a new slide horizontally. This can be changed in the index.html which is currently
condifured as: 

```
                <section data-markdown="content/00_intro/index.md"
                    data-separator="^\n\n\n"
                    data-separator-vertical="^\n\n"
                    data-separator-notes="^Note:"
                    data-charset="iso-8859-15">
                </section>
```

# Local Usage
- Build a new container with updated content

```
docker build -t preso .
```

- Run the container locally specifying the desired content folder

```
docker run -it --rm -e WORKSHOP_NAME=developer_operations -p 8000:8000 preso
```


# Resources and Credit
### Resources
https://github.com/hakimel/reveal.js/wiki/Plugins,-Tools-and-Hardware
https://github.com/byteclubfr/uncloak (CSS Editor)


### Credit
https://github.com/nbrownuk

