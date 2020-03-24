# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([schematron-cli],[0],[https://github.com/webb/schematron-cli/issues],[schematron-cli],[https://github.com/webb/schematron-cli/])

if test "x$prefix" = "xNONE"
then AC_MSG_ERROR([\$prefix is unset. Set with --prefix=\${install root directory}])
fi

# Checks for programs.
AC_PROG_INSTALL
AC_PROG_MKDIR_P
AC_PROG_SED

dnl WR_check_prog( $command-name )
dnl   e.g., WR_check_prog(bash) will set @bash@
AC_DEFUN([WR_check_prog],[AC_PATH_PROG($1,$1)
  test "x$[]$1" = "x" && AC_MSG_ERROR([$1 not found])])dnl

dnl WR_check_prog_options( $command-short-name, $command-name-options ... )
dnl   e.g., WR_check_prog_options(cat, gcat cat) will set @cat@
AC_DEFUN([WR_check_prog_options],[AC_PATH_PROGS($1,$2)
  test "x$[]$1" = "x" && AC_MSG_ERROR([$1 not found])])dnl

# only put critical programs required to build 'all' here.

AC_PATH_PROG([bash],[bash])
test "x$bash" = "x" && AC_MSG_ERROR([bash not found])

AC_PATH_PROGS([find],[gfind find])
test "x$find" = "x" && AC_MSG_ERROR([find not found])

AC_PATH_PROG([stow],[stow],[stow])
AC_PATH_PROG([git],[git],[git])
AC_PATH_PROG([zip],[zip],[zip])

AC_CONFIG_FILES([Makefile], [chmod 444 Makefile])
AC_CONFIG_FILES([stow.mk], [chmod 444 stow.mk])
AC_CONFIG_FILES([zip.mk], [chmod 444 zip.mk])
AC_SUBST([config_files],$ac_config_files)
AC_OUTPUT
