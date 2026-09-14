# AOS-workshop_2026

#### Public repository of materials for *Setting Your Analyses Up For Success With eBird Data: Preparing Raw Data With ‘Auk’ in R*, presented at the 2026 [American Ornithological Society](https://americanornithology.org/) annual meeting in Amherst, Massachusetts, USA.

*Updated September 14, 2026*

**Instructors:** [Aimee M. Van Tatenhove](https://www.avantatenhove.com), Cornell Lab of Ornithology; [Fabiola Rodríguez Vásquez](https://cals.cornell.edu/people/fabiola-rodriguez-vasquez), Cornell University

**Target audience:** Researchers with interest in using [eBird data](https://ebird.org/home) for research and visualization, but who have no to minimal prior experience using eBird data or the [auk R package](https://cornelllabofornithology.github.io/auk/). This workshop is fitting for a broad audience, from graduate students to research associates. Participants must feel comfortable working with [programming language R](https://www.r-project.org/) syntax and know how to navigate a package’s help files, and understand how these explain arguments. Familiarity or working knowledge of the [tidyverse packages](https://tidyverse.org/) is recommended.

**About the auk package:** The auk package was created by [Matthew Strimas-Mackey](http://strimas.com) (author, maintainer), [Eliot Miller](http://eliotmiller.weebly.com/) (author), and [Wesley Hochachka](https://www.birds.cornell.edu/hochachka/) (author). eBird is one of the largest citizen science projects in history. The full eBird database is packaged as a text file and available for download as the [eBird Basic Dataset (EBD)](http://ebird.org/ebird/data/download). Due to the large size of this dataset, it must be filtered to a smaller subset of desired observations before reading into R. This filtering is most efficiently done using AWK, a Unix utility and programming language for processing column formatted text data. The auk package acts as a front end for AWK, allowing users to filter eBird data before import into R.

**Use and citations:** The materials in this repository are available for personal use and we encourage you to build upon them for future research, presentations, or workshops! If you use any of our materials, please credit us, and the auk package creators, appropriately:

*To cite this GitHub repo:*

> ###### Van Tatenhove, A.M., Rodríguez Vásquez, F.G. (2026). *Setting Your Analyses Up For Success With eBird Data: Preparing Raw Data With ‘Auk’ in R.* <https://github.com/s0avant/AOS-workshop_2026>

*To cite the auk package version used in this workshop:*

> ###### Strimas-Mackey, M., Miller, E., Hochachka, W. (2026). *auk: eBird Data Extraction and Processing in R*. R package version 0.9.2, <https://cornelllabofornithology.github.io/auk/>.

*To cite the eBird Basic Dataset version used in this workshop:*

> ###### eBird Basic Dataset. (2026). Version: EBD_relJul-2026. Cornell Lab of Ornithology, Ithaca, New York.

**Further reading and resources:**

- Best Practices for Using eBird Data (version 2.0): <https://ebird.github.io/ebird-best-practices/>
- Quick reference to different auk functions available: <https://cornelllabofornithology.github.io/auk/reference/index.html#section-filter>
- Johnston *et al.* 2021 eBird best practices paper: <https://onlinelibrary.wiley.com/doi/10.1111/ddi.13271>

------------------------------------------------------------------------

### Repository directory structure

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

### Repository file descriptions

#### ./

- **README.md**
  - Project README file formatted in markdown
- **README.html**
  - Project README file formatted in HTML
- **AOS-workshop_2026.Rproj**
  - Rproj file created by RStudio for easy management of working directories. Double-click to open this project in RStudio.

#### ./code

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

#### ./data

- **eBird.zip**
  - Compressed data folder containing eBird Basic Database files. Unzip before beginning workshop.
  - Contains:
    - ebd_filtered_cam_AOS_2026.txt
      - eBird Basic observation dataset for Crested Guan & Northern Emerald-Toucanet in Central America in 2025 & 2026
    - ebd_filtered_us_AOS_2026.txt
      - eBird Basic observation dataset for Black-capped Chickadee, Prairie Warbler, & American Woodcock in the United States in 2025
    - effort_filtered_cam_AOS_2026.txt
      - eBird Basic effort dataset for Crested Guan & Northern Emerald-Toucanet in Central America in 2025 & 2026
    - effort_filtered_us_AOS_2026.txt
      - eBird Basic effort dataset for Black-capped Chickadee, Prairie Warbler, & American Woodcock in the United States in 2025
- **gis.zip**
  - Compressed data folder containing geospatial data files. Unzip before beginning workshop.
    - Contains:
      - EarthEnv-landcover-cam.csv
        - 1-km consensus landcover for Central America provided by EarthEnv (Tuanmu & Jetz 2014)
      - EarthEnv-landcover-northeast.csv
        - 1-km consensus landcover for the northeastern United States provided by EarthEnv (Tuanmu & Jetz 2014)
      - cam-countries.\*
        - Shapefiles (.dbf, .prj, .shp, & .shx formats) of Central American country boundaries provided by geoBoundaries (Runfola et al. 2020)
      - usa-northeast-states.\*
        - Shapefiles (.dbf, .prj, .shp, & .shx formats) of United States state boundaries provided by geoBoundaries (Runfola et al. 2020)

#### ./reference-materials

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

#### ./reference-materials/presentations

- **auk-eBird-AOS_2026.08.01.pdf**
  - Presentation slides: introduction to the auk R package, including how it works, basic functionality, and author information
- **Data Download Exercise.pdf**
  - Presentation slides: exercise for participants to navigate to the eBird Basic Dataset download website and explore download options
- **eBird_AOS_May52026.pptx.pdf**
  - Presentation slides: introduction to eBird and eBird dataset access and structure
- **Welcome.pdf**
  - Presentation slides: overview and goals of the 2026 Amherst workshop

------------------------------------------------------------------------

### Cited works

- eBird Basic Dataset. (2026). Version: EBD_relJul-2026. Cornell Lab of Ornithology, Ithaca, New York.
- Runfola, D. et al. (2020) geoBoundaries: A global database of political administrative boundaries. PLoS ONE 15(4): e0231866. https://doi.org/10.1371/journal.pone.0231866
- Strimas-Mackey, M., Hochachka, W.M., Ruiz-Gutierrez, V., Robinson, O.J., Miller,  E.T., Auer, T., Kelling,  S., Fink, D., Johnston, A. (2023). Best Practices for Using eBird Data. Version 2.0. https://ebird.github.io/ebird-best-practices/. Cornell Lab of Ornithology, Ithaca, New York. https://doi.org/10.5281/zenodo.3620739
- Strimas-Mackey, M., Miller, E., Hochachka, W. (2026). auk: eBird Data Extraction and Processing in R. R package version 0.9.2, <https://cornelllabofornithology.github.io/auk/>.
- Tuanmu, M.-N. and Jetz, W. (2014). A global 1-km consensus land-cover product for biodiversity and ecosystem modeling. Global Ecology and Biogeography 23(9): 1031-1045.
- Wickham, H., Averick, M., Bryan, J., Chang, W., McGowan, L.D., François, R., Grolemund, G., Hayes, A., Henry, L., Hester, J., Kuhn, M., Pedersen, T.L., Miller, E., Bache, S.M., Müller, K., Ooms, J., Robinson, D., Seidel, D.P., Spinu, V., Takahashi, K., Vaughan, D., Wilke, C., Woo, K., Yutani, H. (2019). “Welcome to the tidyverse.” *Journal of Open Source Software*, *4*(43), 1686. <doi:10.21105/joss.01686> <https://doi.org/10.21105/joss.01686>.