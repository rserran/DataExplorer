#' Plot density estimates
#'
#' Plot density estimates for each continuous feature
#' @param data input data
#' @param geom_density_args a list of other arguments to \link{geom_density}
#' @param title plot title
#' @param ggtheme complete ggplot2 themes. The default is \link{theme_gray}.
#' @param theme_config a list of configurations to be passed to \link{theme}.
#' @param nrow number of rows per page. Default is 4.
#' @param ncol number of columns per page. Default is 4.
#' @param parallel enable parallel? Default is \code{FALSE}.
#' @return invisibly return the named list of ggplot objects
#' @keywords plot_density
#' @import data.table
#' @import ggplot2
#' @export
#' @seealso \link{geom_density} \link{plot_histogram}
#' @examples
#' # Plot iris data
#' plot_density(iris, nrow = 2L, ncol = 2L)
#'
#' # Plot random data
#' set.seed(1)
#' data <- data.frame(replicate(16L, rnorm(100)))
#' plot_density(data)
#'
#' # Add color to density area
#' plot_density(data, geom_density_args = list("fill" = "black", "alpha" = 0.6))

plot_density <- function(data, geom_density_args = list(), title = NULL, ggtheme = theme_gray(), theme_config = list(), nrow = 4L, ncol = 4L, parallel = FALSE) {
	## Declare variable first to pass R CMD check
	variable <- value <- NULL
	## Check if input is data.table
	if (!is.data.table(data)) data <- data.table(data)
	## Stop if no continuous features
	if (split_columns(data)$num_continuous == 0) stop("No Continuous Features")
	## Get continuous features
	continuous <- split_columns(data)$continuous
	feature_names <- names(continuous)
	dt <- suppressWarnings(melt.data.table(continuous, measure.vars = feature_names, variable.factor = FALSE))
	## Calculate number of pages
	layout <- .getPageLayout(nrow, ncol, ncol(continuous))
	## Create ggplot object
	plot_list <- .lapply(
		parallel = parallel,
		X = layout,
		FUN = function(x) {
			ggplot(dt[variable %in% feature_names[x]], aes(x = value)) +
				do.call("geom_density", c("na.rm" = TRUE, geom_density_args)) +
				ylab("Density")
		}
	)
	## Plot objects
	class(plot_list) <- c("multiple", class(plot_list))
	plotDataExplorer(
		plot_obj = plot_list,
		page_layout = layout,
		title = title,
		ggtheme = ggtheme,
		theme_config = theme_config,
		facet_wrap_args = list(
			"facet" = ~ variable,
			"nrow" = nrow,
			"ncol" = ncol,
			"scales" = "free"
		)
	)
}
