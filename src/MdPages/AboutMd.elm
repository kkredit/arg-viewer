module MdPages.AboutMd exposing (text)


text : String
text =
    """
# About

### Argument Maps

[Argument maps](https://en.wikipedia.org/wiki/Argument_map) are a tool used to graphically represent an argument's
statements, premises, and conclusions in an easily comprehensible format. They can be helpful in identifying the
complexities of [wicked problems](https://en.wikipedia.org/wiki/Wicked_problem) such as encryption policy.

### "Going Dark" and Exceptional Access

Encryption policy is in flux. Some perceive a ["Going
Dark"](https://www.fbi.gov/news/speeches/going-dark-are-technology-privacy-and-public-safety-on-a-collision-course)
problem, in which encryption is unduly keeping data out of law enforcement's hands, giving criminals too much privacy.
Others perceive a massive invasion of privacy by the government and corporations through electronic data collection. The
former view encryption as a grave threat, while the latter view encryption as a dire necessity. Meanwhile, security
experts remind us that cryptography is central to information security, and safe exceptional access is beyond our
current capabilities.

### This Website

This website is written in [Elm](https://elm-lang.org/) and hosted on GitHub Pages. You can find the source
[here](https://github.com/kkredit/arg-viewer). It uses the wonderful [Argdown](https://argdown.org/) language and
web renderer to construct and display argument maps on encryption policy.
"""
