# CraftSim

## [20.4.0](https://github.com/derfloh205/CraftSim/tree/20.4.0) (2026-02-17)
[Full Changelog](https://github.com/derfloh205/CraftSim/compare/20.3.10...20.4.0) [Previous Releases](https://github.com/derfloh205/CraftSim/releases)

- Update version to 20.4.0 and add new features to news section  
- Add profit margin and TSM sale rate filters to RecipeScan (#945)  
    * Initial plan  
    * Add TSM filter options to RecipeScan scan button  
    - Add RECIPESCAN\_SCAN\_PROFIT\_MARGIN\_THRESHOLD and RECIPESCAN\_SCAN\_TSM\_SALERATE\_THRESHOLD options  
    - Add UI filter inputs in scan options menu (similar to Send to Craft Queue button)  
    - Implement filtering logic in ScanRow to exclude recipes below thresholds  
    - Default values: profit margin 0%, TSM sale rate 0 (no filtering by default)  
    Co-authored-by: derfloh205 <9341090+derfloh205@users.noreply.github.com>  
    * Move filter logic to after optimization completes  
    Filters now apply after recipeData:Optimize() finishes in the finalizeRecipeAndContinue callback, ensuring profit and result item data are accurate for filtering decisions.  
    Co-authored-by: derfloh205 <9341090+derfloh205@users.noreply.github.com>  
    ---------  
    Co-authored-by: copilot-swe-agent[bot] <198982749+Copilot@users.noreply.github.com>  
    Co-authored-by: derfloh205 <9341090+derfloh205@users.noreply.github.com>  