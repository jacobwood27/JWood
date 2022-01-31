@def author = "Jacob Wood"
@def mintoclevel = 2
@def prepath = ""

@def website_title = "Jacob Wood Personal Website"
@def website_descr = ""
@def website_url   = "https://jacobw.xyz"



\newcommand{\lineskip}{@@blank@@}
\newcommand{\skipline}{\lineskip}
\newcommand{\note}[2]{@@note @@title #1 @@ @@content #2 @@ @@}
\newcommand{\posttitle}[3]{
    ~~~ 
    <p style="text-align:left;">
        <a href=#2> #1 </a>
        <span style="float:right;">
            <em>#3</em>
        </span>
    </p> 
    ~~~
}