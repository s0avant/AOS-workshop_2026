# AOS-workshop_2026

##### Public repository of materials for *Setting Your Analyses Up For Success With eBird Data: Preparing Raw Data With ‘Auk’ in R*, presented at the 2026 [American Ornithological Society](https://americanornithology.org/) annual meeting in Amherst, Massachusetts, USA.

*Updated September 14, 2026*

**Instructors:** [Aimee M. Van Tatenhove](https://www.avantatenhove.com), Cornell Lab of Ornithology; Fabiola Rodríguez Vásquez, Cornell University

**Target audience:** Researchers with interest in using [eBird data](https://ebird.org/home) for research and visualization, but who have no to minimal prior experience using eBird data or the [auk R package](https://cornelllabofornithology.github.io/auk/). This workshop is fitting for a broad audience, from graduate students to research associates. Participants must feel comfortable working with [programming language R](https://www.r-project.org/) syntax and know how to navigate a package’s help files, and understand how these explain arguments. Familiarity or working knowledge of the [tidyverse packages](https://tidyverse.org/) is recommended.

**About the auk package:** The auk package was created by [Matthew Strimas-Mackey](http://strimas.com) (author, maintainer), [Eliot Miller](http://eliotmiller.weebly.com/) (author), and [Wesley Hochachka](https://www.birds.cornell.edu/hochachka/) (author). eBird is one of the largest citizen science projects in history. The full eBird database is packaged as a text file and available for download as the [eBird Basic Dataset (EBD)](http://ebird.org/ebird/data/download). Due to the large size of this dataset, it must be filtered to a smaller subset of desired observations before reading into R. This filtering is most efficiently done using AWK, a Unix utility and programming language for processing column formatted text data. The auk package acts as a front end for AWK, allowing users to filter eBird data before import into R.

**Use and citations:** The materials in this repository are available for personal use and we encourage you to build upon them for future research, presentations, or workshops! If you use any of our materials, please credit us, and the auk package creators, appropriately:

*To cite this GitHub repo:*

> ###### Van Tatenhove, A.M., Rodríguez Vásquez, F.G. (2026). *Setting Your Analyses Up For Success With eBird Data: Preparing Raw Data With ‘Auk’ in R.* <https://github.com/s0avant/AOS-workshop_2026>

*To cite the auk package:*

> ###### Strimas-Mackey, M., Miller, E., Hochachka, W. (2026). *auk: eBird Data Extraction and Processing in R*. R package version 0.9.2, <https://cornelllabofornithology.github.io/auk/>.

**Further reading and resources:**

- Best Practices for Using eBird Data (version 2.0): <https://ebird.github.io/ebird-best-practices/>
- Quick reference to different auk functions available: <https://cornelllabofornithology.github.io/auk/reference/index.html#section-filter>
- Johnston *et al.* 2021 eBird best practices paper: <https://onlinelibrary.wiley.com/doi/10.1111/ddi.13271>

------------------------------------------------------------------------

#### Repository directory structure

```         
.
├── AOS-workshop_2026.Rproj
├── code
│   ├── 00_full_workshop.qmd
│   ├── 00_full_workshop.R
│   ├── 01-import-and-explore-auk-data.qmd
│   ├── 02-using-auk-filters.qmd
│   ├── 03-zerofilling-auk-data.qmd
│   ├── 04-auk-practice.qmd
│   ├── check_auk-runs.R
│   ├── clean-shapefiles-rasters.R
│   └── custom-functions.R
├── data
│   ├── eBird.zip
│   └── gis.zip
├── README.html
├── README.md
└── reference_materials
    ├── 00_full_workshop_original.pdf
    ├── AOS 2026 auk workshop resources.pdf
    ├── auk-cheatsheet.pdf
    ├── AWK-install-instructions_AOS-2026.pdf
    ├── eBird_Basic_Dataset_Metadata_v1.16.pdf
    └── presentations
        ├── auk-eBird-AOS_2026.08.01.pdf
        ├── Data Download Exercise.pdf
        ├── eBird_AOS_May52026.pptx.pdf
        └── Welcome.pdf
```

#### Repository file descriptions

##### ./

- **README.md**
  - Project README file formatted in markdown
- **README.html**
  - Project README file formatted in HTML
- **AOS-workshop_2026.Rproj**
  - Rproj file created by RStudio for easy management of working directories. Double-click to open this project in RStudio.

##### ./code

- **00_full_workshop.qmd**
  - Reference (completed) Quarto document containing explanatory text and R code for all workshop demonstrations and exercises
- **00_full_workshop.R**
  - Reference (completed) R script containing code for all workshop demonstrations and exercises
- **01-import-and-explore-auk-data.qmd**
  - Teaching (incomplete i.e., "code-along") Quarto document containing explanatory text and R code for part 1 of the workshop
- **02-using-auk-filters.qmd**
  - Teaching (incomplete i.e., "code-along") Quarto document containing explanatory text and R code for part 2 of the workshop
- **03-zerofilling-auk-data.qmd**
  - Teaching (incomplete i.e., "code-along") Quarto document containing explanatory text and R code for part 3 of the workshop
- **04-auk-practice.qmd**
  - Teaching (incomplete i.e., "code-along") Quarto document containing explanatory text and R code for part 4 of the workshop
- **check_auk-runs.R**
  - R script for use in testing whether AWK and required R packages have been installed correctly. Run before beginning workshop.
- **clean-shapefiles-rasters.R**
  - R script demonstrating how shapefiles and spatial rasters were prepared for workshop exercises
- **custom-functions.R**
  - R script containing custom functions and ggplot themes

##### ./data

- **eBird.zip**
  - Compressed data folder containing eBird Basic Database files. Unzip before beginning workshop.
- **gis.zip**
  - Compressed data folder containing geospatial data files. Unzip before beginning workshop.

##### ./reference-materials

- **00_full_workshop_original.pdf**
  - Rendered PDF document of full workshop code and exercises presented at the AOS 2026 conference.
    - *Note:* the file sizes of US EBD and effort datasets were reduced to allow for easy GitHub upload. Plots and data summaries in this document will differ slightly from those produced using the US datasets contained in this repository.
- **AOS 2026 auk workshop resources.pdf**
  - A list of helpful resources for learning auk and using eBird data for research purposes
- **auk-cheatsheet.pdf**
  - Reference sheet to important auk functions
- **AWK-install-instructions_AOS-2026.pdf**
  - Reference manual for downloading and installing AWK on Windows computers
    - *Note:* This must be completed for Windows computers prior to beginning the workshop. Mac and Linux computers come with AWK pre-installed.
- **eBird_Basic_Dataset_Metadata_v1.16.pdf**
  - Information about the eBird Basic Dataset

##### ./reference-materials/presentations

- **auk-eBird-AOS_2026.08.01.pdf**
  - Presentation slides: introduction to the auk R package, including how it works, basic functionality, and author information
- **Data Download Exercise.pdf**
  - Presentation slides: exercise for participants to navigate to the eBird Basic Dataset download website and explore download options
- **eBird_AOS_May52026.pptx.pdf**
  - Presentation slides: introduction to eBird and eBird dataset access and structure
- **Welcome.pdf**
  - Presentation slides: overview and goals of the 2026 Amherst workshop
