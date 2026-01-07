enum AuthResolution {
  //if mgits
    //if in profiles
  inactive, 
  banned, 
  student, 
  faculty, 
  admin,
    //if not in profiles
  needsOnboarding,
  notAdded,

  //if not mgits
  unauthorized,

  //default
  unauthenticated
}
