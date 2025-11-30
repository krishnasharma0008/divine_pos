enum RoutePages {
  flashScreen,
  dashboard,
  home,
  login,
  otp,
  profile,
  priceList,
  estimate,
}

extension RoutePagesExtension on RoutePages {
  String get routePath {
    switch (this) {
      case RoutePages.flashScreen:
        return "/flash_screen";

      case RoutePages.home:
        return "/home";

      case RoutePages.dashboard:
        return "/dashboard";

      case RoutePages.login:
        return "/login";

      case RoutePages.otp:
        return "/otp";

      case RoutePages.profile:
        return "/profile";

      case RoutePages.priceList:
        return "/price_list";

      case RoutePages.estimate:
        return "/estimate";
    }
  }

  String get routeName {
    switch (this) {
      case RoutePages.flashScreen:
        return "flash_screen";

      case RoutePages.home:
        return "home";

      case RoutePages.dashboard:
        return "dashboard";

      case RoutePages.login:
        return "login";

      case RoutePages.otp:
        return "otp";

      case RoutePages.profile:
        return "profile";

      case RoutePages.priceList:
        return "price_list";

      case RoutePages.estimate:
        return "estimate";
    }
  }

  String get routePageHeaderName {
    switch (this) {
      case RoutePages.flashScreen:
        return "Flash Screen";

      case RoutePages.home:
        return "Home";

      case RoutePages.dashboard:
        return "Dashboard";

      case RoutePages.login:
        return "Login";

      case RoutePages.otp:
        return "OTP";

      case RoutePages.profile:
        return "Profile";

      case RoutePages.priceList:
        return "Price List";

      case RoutePages.estimate:
        return "Estimate";
    }
  }
}
