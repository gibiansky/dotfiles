% Andrew Gibiansky
% Problem Set Class
\NeedsTeXFormat{LaTeX2e}[1995/01/01]
\ProvidesClass{pset}

% Based on article class
\LoadClass{article}

% Required packages
\RequirePackage{amsmath,amssymb,amsthm,amsfonts}
\RequirePackage{commath}
\RequirePackage{boxedminipage}
\RequirePackage{lastpage}
\RequirePackage{xparse}
\RequirePackage{xstring}
\RequirePackage{enumitem}
\RequirePackage{cancel}
\RequirePackage{array}
\RequirePackage{nicefrac}
\RequirePackage{geometry}
\RequirePackage{fancyhdr}
\RequirePackage{float}
\RequirePackage{etoolbox}
\RequirePackage{fancybox}
\RequirePackage{environ}
\RequirePackage{changepage}

% Forcefully disable the 'minted' package
\newbool{allowminted}
\newbool{useminted}
\booltrue{allowminted}
\booltrue{useminted}
\DeclareOption{nominted}{%
    \boolfalse{allowminted}
}
\ProcessOptions\relax

% Document margins and widths
\setlength{\textwidth}{19.3cm}

% Header, footer, and page layout
\pagestyle{fancy}
\geometry{left=1.2cm,right=1.4cm,top=2cm,bottom=1.5cm}
\geometry{letterpaper}
\setlength{\oddsidemargin}{-40pt}
\lhead{\pset@name}
\chead{%
    \ifnum\thepage=1
        Due \pset@duedate
    \else
        \bf \pset@assignment
    \fi
}
\rhead{\pset@class}
\lfoot{}
\cfoot{\thepage\ of \pageref{LastPage}}
\rfoot{}
\renewcommand{\headrulewidth}{0.4pt}
\renewcommand{\footrulewidth}{0.4pt}
\geometry{headsep=7pt, top=40pt}

% Metadata for this problem set
\def\pset@name{}
\def\pset@class{}
\def\pset@assignment{}
\def\pset@duedate{}

% Commands to set problem set metadata
\newcommand{\name}[1]{\def\pset@name{#1}}
\newcommand{\class}[1]{\def\pset@class{#1}}
\newcommand{\assignment}[1]{\def\pset@assignment{#1}}
\newcommand{\duedate}[1]{\def\pset@duedate{#1}}

%%% Custom commands and environments %%%

% Helper command to define list types
\newcommand\deflist[2]{
    \newenvironment{#1}{
        \begin{enumerate}[label=#2]
        \setlength{\itemsep}{-3pt}%
    }{
        \end{enumerate}
    }
}

% Define types of lists
\deflist{a)}{\alph{*})}
\deflist{a.}{\alph{*}.}
\deflist{bold-a.}{\textbf{\alph{*}.}}
\deflist{bold-(a)}{\textbf{(\alph{*})}}
\deflist{(i)}{(\roman{*})}
\deflist{(I)}{(\Roman{*})}
\deflist{(a)}{(\alph{*})}
\deflist{(1)}{(\arabic{*})}
\deflist{1)}{\arabic{*})}
\deflist{1.}{\arabic{*}.}

% Start the list of problems:
%   Create the problem counter, initialized to 1.
%   Define the global 'current section' variable.
\newcommand{\startproblemlist}{%
    \newcounter{problemcounter}%
    \setcounter{problemcounter}{1}%
    \global\edef\pset@currentsection{}
}

% End the list of problems:
%   Reset the problem counter to 1 to prepare for problem definitions.
\newcommand{\finishproblemlist}{
    \setcounter{problemcounter}{1}
}

% Define a problem name:
%   Define the \problemarrayn command as the problem, where n = problemcounter
%   Increment the problem counter
\newcommand{\defproblemname}[1]{
    \expandafter\newcommand\csname problemarray\the\value{problemcounter} \endcsname{#1}
    \stepcounter{problemcounter}
}

% Create a parsing problem list command:
%   Split the argument along commas.
%   Process each argument in order, defining the problems with the substrings.
\DeclareDocumentCommand \problemlistinternal
    { > { \SplitList {,} } m }
    { \ProcessList {#1} {\defproblemname} }

% Create a problem list, usable externally:
%   Start the problem list, define problems, end the problem list.
%   Output a neat centered problem list.
%   An optional argument may be provided to give the list a different title; by default,
%   the name of the current assignment is used. 
%
%   Example: \problems{(3.2) 4, 20, 22, (3.3) 3, 8, 9}
%   Example: \problems[Optional Name]{(3.2) 4, 20, 22, (3.3) 3, 8, 9}
\DeclareDocumentCommand\problemlist{O{\pset@assignment}m}{
    \startproblemlist
    \problemlistinternal{#2}
    \finishproblemlist
    \large
    \centerline{\textbf{#1:} #2.}
    \normalsize
    \vspace{12pt}
}

% Retrieve the name of a problem and process it.
\newcommand{\problemname}[1]{
    % Retrieve the problem name.
    \def\probname{\csname problemarray#1 \endcsname}%
%
    % Check if this problem name contains a section name.
    \IfSubStr{\probname}{(}{%
        % Get everything before the close paren as the section name.
        \StrBefore{\probname}{)}[\presect]%
%
        % Redefine the current section name to be the new section.
        \global\edef\pset@currentsection{\presect)}%
%
        % Chop off the section name from this problem name.
        \StrBehind{\probname}{) }[\probname]%
    }{}%
%
    % Output the section followed by the problem number.
    \StrSubstitute{\pset@currentsection \probname}{)}{) }%
}

% Define the problem environment.
\NewDocumentEnvironment{problem}{ }{%
    % Begin the boxed page.
    \Sbox
    \minipage{\columnwidth}
%   
    % Declare the problem section and number.
    \textbf{\problemname{\the\value{problemcounter}}}
}{%
    % Advance to the next problem.
    \stepcounter{problemcounter}%
%
    % End the boxed page.
    \endminipage%
    \endSbox%
    \doublebox{\TheSbox}%
    \vspace*{10pt}%
}

\newlength{\currentparskip}
\newlength{\currentparindent}
\setlength{\parindent}{0cm}
% Define the solution environment.
\NewDocumentEnvironment{solution}{ }{%
    \setlength{\currentparskip}{\parskip}%
    \setlength{\currentparindent}{\parindent}%
    \setlength{\parindent}{0.6cm}%
    \setlength{\parskip}{0.3cm}%
    \indent%
}{%
    \hfill$\scriptscriptstyle \blacksquare$%
    \vspace*{10pt}%
    \setlength{\parskip}{\currentparskip}%
    \setlength{\parindent}{\currentparindent}%
}

% Subparts

% Define a boolean variable indicating whether we're inside the solution environment
\newbool{insidesolution}
\AtBeginEnvironment{solution}{\booltrue{insidesolution}}

% Global counter for which subpart we're on
\newcounter{subpartcounter}
\setcounter{subpartcounter}{1}
\newcommand{\defsubpart}[1]{
    \expandafter\gdef\csname subpartarray\the\value{subpartcounter} \endcsname{#1}
}

% Reset the subpart counter both in solution and problem
\AtBeginEnvironment{solution}{
    \setcounter{subpartcounter}{1}
}
\AtBeginEnvironment{problem}{
    \setcounter{subpartcounter}{1}
}

% Record a subpart (if inside the problem) or output a subpart (if inside the solution).
\newcommand\subpart[1]{%
    \ifbool{insidesolution}{%
        % Inside solution environment
%
        % Retrieve the subpart problem text
        \def\subparttext{\csname subpartarray\the\value{subpartcounter} \endcsname}%

        % If this is the first subpart, adjust spacing. The newline is important.
        \ifnum\value{subpartcounter}=1%
            \vspace*{-0.5cm}

            \indent%
        \else%
            \indent%
        \fi%
%
        % Enclose the subpart problem text in a fancy box
        \ovalbox{\textbf{(\alph{subpartcounter})} \subparttext}\\
%
        % Include the subpart answer
        %\indent \begin{minipage}[t]{0.9\textwidth}
        %    \setlength{\parindent}{0.6cm}
        %    \setlength{\parskip}{0.3cm}
        %    #1\\
        %\end{minipage}
        \begin{adjustwidth}{0.05\textwidth}{0.05\textwidth}
            \setlength{\parindent}{0.6cm}
            \setlength{\parskip}{0.3cm}
            #1\\
        \end{adjustwidth}

    }{%
        % Inside problem environment
%
        % Define the subpart problem text for later use
        \defsubpart{
            \begin{minipage}[t]{0.87\textwidth}
                #1
            \end{minipage}
        }
%
        % Adjust spacing for the first subpart
        \ifnum\value{subpartcounter}=1%
            \vspace*{7pt}
        \else
            \\
        \fi%
%
        % Output the subpart problem text as a list
        \hspace*{40pt} \begin{minipage}[t]{0.9\textwidth}
            \hspace*{-21pt} \textbf{(\alph{subpartcounter})}  #1
        \end{minipage}
    }%
%
    % Advance to the next subpart
    \stepcounter{subpartcounter}%
}

%%% Common source-code processing options %%%

\ifbool{allowminted}{%
    \IfFileExists{minted.sty}{%
        \RequirePackage{minted}
        \booltrue{useminted}

    }{%
        \RequirePackage{sverb}
        \boolfalse{useminted}
        \PackageWarning{minted}{%
            Package 'minted' not available, therefore\MessageBreak
            substituting environment 'verbatim' for 'minted'\MessageBreak
        }%
    }%
}{%
    \RequirePackage{sverb}
    \boolfalse{useminted}
}%

\newcommand{\matlabfile}[1]{
    \ifbool{useminted}{%
        \inputminted{matlab}{#1}
    }{
        \verbinput{#1}
    }
}

\newcommand{\pythonfile}[1]{
    \ifbool{useminted}{%
        \inputminted{python}{#1}
    }{
        \verbinput{#1}
    }
}


%%% Common mathematical shortcuts %%%

% Matrix environments
\newcommand{\bmatr}[1] {\begin{bmatrix} #1 \end{bmatrix}}
\newcommand{\pmatr}[1] {\left( \begin{matrix} #1 \end{matrix}\right)}
\newcommand{\matr}[1] {\begin{array}{ccc} #1 \end{array}}

\newcommand{\piecewise}[1] { \left\{ \begin{array}{cl} #1 \end{array} \right.}
\newcommand{\e}[1] {\ensuremath{\times 10^{#1}}}
\newcommand{\expect}[1] {\textbf{E}\!\left[ {#1} \right]}
\newcommand{\inv}[1] {\frac{1}{#1}}
\newcommand{\invnice}[1] {\nicefrac{1}{#1}}
\newcommand{\dd}{\dif}
\newcommand{\p}[2] {\ensuremath{\frac{\partial #1}{\partial #2}}}
\newcommand{\angles}[1]{\langle #1 \rangle}

% Common sets
\newcommand{\DeclareSet}[1]{
    % Declare a set using \mathbb
    \expandafter\newcommand\csname #1\endcsname{\ensuremath{\mathbb{#1}}}
}
\newcommand{\DeclareCurlySet}[1]{
    % Declare a set using \mathcal
    \expandafter\newcommand\csname c#1\endcsname{\ensuremath{\mathcal{#1}}}
}
\DeclareSet{N}
\DeclareSet{Z}
\DeclareSet{Q}
\DeclareSet{R}
\DeclareSet{C}

\DeclareCurlySet{L}
\DeclareCurlySet{C}
\DeclareCurlySet{E}
\DeclareCurlySet{D}
\DeclareCurlySet{F}
\DeclareCurlySet{B}
\DeclareCurlySet{P}
\DeclareCurlySet{O}

% Math operators not included in other packages
\DeclareMathOperator{\image}{image}
\DeclareMathOperator{\range}{range}
\DeclareMathOperator{\nullspace}{null}
\DeclareMathOperator{\Tr}{Tr}

% Nice vector hack
\usepackage{harpoon}
\makeatletter
\newcommand{\oset}[2]{{\mathop{#2}\limits^{\vbox to -.5\ex@{\kern-\tw@\ex@\hbox{\scriptsize $#1$}\vss}}}}
\makeatother
\renewcommand{\v}[1]{\oset{\rightharpoonup}#1}
