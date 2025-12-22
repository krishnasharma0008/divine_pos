enum RoutePages {
  flashScreen,
  dashboard,
  home,
  login,
  otp,
  profile,
  priceList,
  estimate,
  jewellerylisting,
  jewelleryjourney,
  catalogue,
  feedback,
  knowDiamond,
  verifyTrack,
  cart,
  account,
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

      case RoutePages.jewellerylisting:
        return "/jewellery_listing";

      case RoutePages.jewelleryjourney:
        return "/jewellery_journey";

      case RoutePages.catalogue:
        return "/catalogue";

      case RoutePages.feedback:
        return "/feedback";

      case RoutePages.knowDiamond:
        return "/know_diamond";

      case RoutePages.verifyTrack:
        return "/verify_track";

      case RoutePages.cart:
        return "/cart";

      case RoutePages.account:
        return "/accounts";

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

      case RoutePages.jewellerylisting:
        return "jewellery_listing";

      case RoutePages.jewelleryjourney:
        return "jewellery_journey";

      case RoutePages.catalogue:
        return "catalogue";

      case RoutePages.feedback:
        return "feedback";

      case RoutePages.knowDiamond:
        return "know_diamond";

      case RoutePages.verifyTrack:
        return "verify_track";

      case RoutePages.cart:
        return "cart";

      case RoutePages.account:
        return "accounts";

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

      case RoutePages.jewellerylisting:
        return "Jewellery Listing";

      case RoutePages.jewelleryjourney:
        return "Jewellery Journey";

      case RoutePages.catalogue:
        return "Catalogue";

      case RoutePages.feedback:
        return "Feedback";

      case RoutePages.knowDiamond:
        return "Know Diamond";

      case RoutePages.verifyTrack:
        return "Verify / Track";

      case RoutePages.cart:
        return "Cart";

      case RoutePages.account:
        return "Account";

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
