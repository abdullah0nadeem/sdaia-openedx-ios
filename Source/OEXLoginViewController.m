//
//  OEXLoginViewController.m
//  edXVideoLocker
//
//  Created by Nirbhay Agarwal on 15/05/14.
//  Copyright (c) 2014 edX. All rights reserved.
//

@import edXCore;

#import "OEXLoginViewController.h"
#import "edX-Swift.h"
#import <Masonry/Masonry.h>
#import "NSString+OEXValidation.h"
#import "NSJSONSerialization+OEXSafeAccess.h"
#import "OEXAnalytics.h"
#import "OEXAppDelegate.h"
#import "OEXCustomButton.h"
#import "OEXCustomLabel.h"
#import "OEXAuthentication.h"
#import "OEXFBSocial.h"
#import "OEXFacebookAuthProvider.h"
#import "OEXFacebookConfig.h"
#import "OEXGoogleAuthProvider.h"
#import "OEXGoogleConfig.h"
#import "OEXGoogleSocial.h"
#import "OEXInterface.h"
#import "OEXNetworkConstants.h"
#import "OEXSession.h"
#import "OEXUserDetails.h"
#import "OEXUserLicenseAgreementViewController.h"
#import "Reachability.h"
#import "OEXStyles.h"
#import "NafathAuthentication.h"

#define USER_EMAIL @"USERNAME"

@interface OEXLoginViewController () <AgreementTextViewDelegate, InterfaceOrientationOverriding, MFMailComposeViewControllerDelegate, SegmentControllerDelegate, TermsAndPolicyTextViewDelegate>
{
    CGPoint originalOffset;     // store the offset of the scrollview.
    UITextField* activeField;   // assign textfield object which is in active state.
    ExternalAuthOptionsView* externalAuthOptions;
}
@property (nonatomic, strong) NSString* str_ForgotEmail;
@property (nonatomic, strong) NSString* signInID;
@property (nonatomic, strong) NSString* signInPassword;
@property (nonatomic, assign) BOOL reachable;
@property (strong, nonatomic) IBOutlet UIView* externalAuthContainer;
@property (nonatomic, strong) IBOutlet UIImageView* seperatorLeft;
@property (nonatomic, strong) IBOutlet UIImageView* seperatorRight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* externalAuthContainerTop;
@property (weak, nonatomic, nullable) IBOutlet SegmentControllerView* segmentControllerView;
@property (weak, nonatomic, nullable) IBOutlet LogistrationTextField* tf_EmailID;
@property (weak, nonatomic, nullable) IBOutlet LogistrationTextField* tf_Password;
@property (weak, nonatomic, nullable) IBOutlet UIView* emailView;
@property (weak, nonatomic, nullable) IBOutlet UIView* passwordView;
@property (weak, nonatomic, nullable) IBOutlet UIButton* btn_TroubleLogging;
@property (weak, nonatomic, nullable) IBOutlet NSLayoutConstraint* troubleLoginButtonTop;
@property (weak, nonatomic, nullable) IBOutlet NSLayoutConstraint* troubleLoginButtonHeight;
@property (weak, nonatomic, nullable) IBOutlet UIButton* btn_Login;
@property (weak, nonatomic, nullable) IBOutlet UIScrollView* scroll_Main;
@property (weak, nonatomic, nullable) IBOutlet UIImageView* img_Logo;
@property (weak, nonatomic, nullable) IBOutlet UILabel* usernameTitleLabel;
@property (weak, nonatomic, nullable) IBOutlet UILabel* passwordTitleLabel;
@property (weak, nonatomic) IBOutlet AgreementTextView *agreementTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *agreementTextViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *agreementTextViewTop;
@property (weak, nonatomic, nullable) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel* versionLabel;
@property (nonatomic, assign) id <OEXExternalAuthProvider> authProvider;
@property (nonatomic) OEXTextStyle *placeHolderStyle;
@property (weak, nonatomic) IBOutlet UIView *logo_container;

#pragma mark Nafath properties
@property (nonatomic, strong) NSString* nafathID;
@property (nonatomic, strong) NSString* nafathTransactionID;
@property (nonatomic, assign) BOOL isNafathFlow;
@property (nonatomic, assign) BOOL isNafathRegistrationFlow;
@property (nonatomic, assign) BOOL isTermsAndPolicySelected;

#pragma mark Registeration form datafields
@property (nonatomic, strong) Gender* selectedGender;
@property (nonatomic, strong) NafathRegion* selectedRegion;
@property (nonatomic, strong) EducationLevel* selectedLevelOfEducation;
@property (nonatomic, strong) EnglishLanguageLevel* selectedEnglishLanguageLevel;
@property (nonatomic, strong) EmploymentStatus* selectedEmploymentStatus;
@property (nonatomic, strong) WorkExperienceLevel* selectedWorkExperienceLevel;

#pragma mark Nafath login outlets
@property (weak, nonatomic, nullable) IBOutlet UIView* nafathIDView;
@property (weak, nonatomic, nullable) IBOutlet UILabel* nafathTitleLabel;
@property (weak, nonatomic, nullable) IBOutlet LogistrationTextField* tf_nafathID;
@property (weak, nonatomic, nullable) IBOutlet UIView* nafathPinView;
@property (weak, nonatomic, nullable) IBOutlet UILabel* nafathPinTitleLabel;
@property (weak, nonatomic, nullable) IBOutlet LogistrationTextField* tf_nafathPin;

#pragma mark Nafath registration outlets
@property (weak, nonatomic, nullable) IBOutlet UIView* fullnameView;
@property (weak, nonatomic, nullable) IBOutlet UILabel* fullnameLabel;
@property (weak, nonatomic, nullable) IBOutlet LogistrationTextField* tf_fullname;
@property (weak, nonatomic, nullable) IBOutlet UIView* publicUsernameView;
@property (weak, nonatomic, nullable) IBOutlet UILabel* publicUsernameLabel;
@property (weak, nonatomic, nullable) IBOutlet LogistrationTextField* tf_publicUsername;
@property (weak, nonatomic, nullable) IBOutlet UIView* nafathEmailView;
@property (weak, nonatomic, nullable) IBOutlet UILabel* nafathEmailLabel;
@property (weak, nonatomic, nullable) IBOutlet LogistrationTextField* tf_nafathEmail;
@property (weak, nonatomic, nullable) IBOutlet UIView* phoneView;
@property (weak, nonatomic, nullable) IBOutlet UILabel* phoneLabel;
@property (weak, nonatomic, nullable) IBOutlet LogistrationTextField* tf_phone;
@property (weak, nonatomic, nullable) IBOutlet RegistrationPickerView* regionPickerView;
@property (weak, nonatomic, nullable) IBOutlet UIView* cityView;
@property (weak, nonatomic, nullable) IBOutlet UILabel* cityLabel;
@property (weak, nonatomic, nullable) IBOutlet LogistrationTextField* tf_city;
@property (weak, nonatomic, nullable) IBOutlet UIView* addressView;
@property (weak, nonatomic, nullable) IBOutlet UILabel* addressLabel;
@property (weak, nonatomic, nullable) IBOutlet LogistrationTextField* tf_address;
@property (weak, nonatomic, nullable) IBOutlet RegistrationPickerView* educationPickerView;
@property (weak, nonatomic, nullable) IBOutlet RegistrationPickerView* englishLevelPickerView;
@property (weak, nonatomic, nullable) IBOutlet RegistrationPickerView* employmentStatusPickerView;
@property (weak, nonatomic, nullable) IBOutlet RegistrationPickerView* workExperiencePickerView;
@property (weak, nonatomic, nullable) IBOutlet UIView* jobTitleView;
@property (weak, nonatomic, nullable) IBOutlet UILabel* jobTitleLabel;
@property (weak, nonatomic, nullable) IBOutlet LogistrationTextField* tf_jobTitle;
@property (weak, nonatomic, nullable) IBOutlet UIView* genderButtonsView;
@property (weak, nonatomic, nullable) IBOutlet UILabel* genderLabel;
@property (weak, nonatomic, nullable) IBOutlet UIButton* maleButton;
@property (weak, nonatomic, nullable) IBOutlet UIButton* femaleButton;
@property (weak, nonatomic, nullable) IBOutlet UILabel* dateOfBirthLabel;
@property (weak, nonatomic, nullable) IBOutlet UIDatePicker* calenderDatePicker;
@property (weak, nonatomic, nullable) IBOutlet UIView* activationCodeView;
@property (weak, nonatomic, nullable) IBOutlet UILabel* activationCodeLabel;
@property (weak, nonatomic, nullable) IBOutlet LogistrationTextField* tf_activationCode;
@property (weak, nonatomic, nullable) IBOutlet UIView* termsAndPolicyView;
@property (weak, nonatomic, nullable) IBOutlet UIImageView* termsAndPolicyImageView;
@property (weak, nonatomic, nullable) IBOutlet TermsAndPolicyTextView* termsAndPolicyTextView;
@property (weak, nonatomic, nullable) IBOutlet UIButton* proceedButton;
@property (weak, nonatomic, nullable) IBOutlet UIButton* completeButton;

@end

@implementation OEXLoginViewController

- (void)layoutSubviews {
    if(!([self isFacebookEnabled] || [self isGoogleEnabled])) {
        self.seperatorLeft.hidden = YES;
        self.seperatorRight.hidden = YES;
        self.agreementTextViewTop.constant = -30;
    }
}


#pragma mark - NSURLConnection Delegtates

#pragma mark - Init

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.view setUserInteractionEnabled:NO];
    
    _nafathID = nil;
    _nafathTransactionID = nil;
    _selectedGender = nil;
    _selectedRegion = nil;
    _selectedLevelOfEducation  = nil;
    _selectedEnglishLanguageLevel = nil;
    _selectedEmploymentStatus  = nil;
    _selectedWorkExperienceLevel  = nil;
    externalAuthOptions = nil;
}

- (BOOL)isFacebookEnabled {
    return [self.environment.config facebookConfig].enabled;
}

- (BOOL)isGoogleEnabled {
    return [self.environment.config googleConfig].enabled;
}

- (BOOL)isMicrosoftEnabled {
    return [self.environment.config microsoftConfig].enabled;
}

- (BOOL)isAppleEnabled {
    return self.environment.config.isAppleSigninEnabled;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isNafathFlow = YES;
    self.isNafathRegistrationFlow = NO;
    [self setTitle:[Strings signInText]];

    NSMutableArray* providers = [[NSMutableArray alloc] init];
    if([self isGoogleEnabled]) {
        [providers addObject:[[OEXGoogleAuthProvider alloc] init]];
    }
    if([self isFacebookEnabled]) {
        [providers addObject:[[OEXFacebookAuthProvider alloc] init]];
    }
    
    if([self isMicrosoftEnabled]) {
        [providers addObject:[[OEXMicrosoftAuthProvider alloc] init]];
    }
    
    if([self isAppleEnabled]) {
        [providers addObject:[[AppleAuthProvider alloc] init]];
    }
    
    __weak __typeof(self) owner = self;
    
    externalAuthOptions = [[ExternalAuthOptionsView alloc] initWithFrame:self.externalAuthContainer.bounds providers:providers type:ExternalAuthOptionsTypeLogin tapAction:^(id<OEXExternalAuthProvider> provider) {
        [owner externalLoginWithProvider:provider];
    }];
    
    [self.externalAuthContainer addSubview:externalAuthOptions];
    [externalAuthOptions mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.externalAuthContainer);
    }];
    
    [self.externalAuthContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo([NSNumber numberWithFloat:externalAuthOptions.height]);
    }];
    
    if (self.environment.config.isRegistrationEnabled && self.environment.config.isEDXEnabled) {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(navigateBack)];
        closeButton.accessibilityLabel = [Strings close];
        closeButton.accessibilityIdentifier = @"LoginViewController:close-bar-button-item";
        self.navigationItem.leftBarButtonItem = closeButton;
    }
    
    [self setExclusiveTouch];
    
    if ([self isRTL]) {
        [self.btn_TroubleLogging setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        self.segmentControllerView.collectionView.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    }
    
    self.tf_EmailID.textAlignment = NSTextAlignmentNatural;
    self.tf_Password.textAlignment = NSTextAlignmentNatural;
    self.logo_container.isAccessibilityElement = YES;
    self.logo_container.accessibilityLabel = [[OEXConfig sharedConfig] platformName];
    self.logo_container.accessibilityHint = [Strings accessibilityImageVoiceOverHint];
    self.segmentControllerView.delegate = self;
    self.nafathPinView.hidden = YES;
    [self.termsAndPolicyImageView setTintColor:[[OEXStyles sharedStyles]secondaryBaseColor]];
    self.calenderDatePicker.maximumDate = [[NSDate alloc] init];
    [self setupNafathRegistrationPicker];
    
    [self.proceedButton applyButtonStyleWithStyle:[self.environment.styles filledPrimaryButtonStyle] withTitle:[Strings nafathAccountCreation]];
    
    [self.completeButton applyButtonStyleWithStyle:[self.environment.styles filledPrimaryButtonStyle] withTitle:[Strings nafathCompleteRegistration]];
    
    [self.maleButton setTitle:Gender.male.value forState:UIControlStateNormal];
    [self.femaleButton setTitle:Gender.female.value forState:UIControlStateNormal];
    [self.maleButton.titleLabel setFont:[[OEXStyles sharedStyles] regularFontOfSize:14]];
    [self.femaleButton.titleLabel setFont:[[OEXStyles sharedStyles] regularFontOfSize:14]];
    [self.maleButton.titleLabel setTextColor:[[OEXStyles sharedStyles] neutralBlackT]];
    [self.femaleButton.titleLabel setTextColor:[[OEXStyles sharedStyles] neutralBlackT]];
    [self.maleButton setTintColor:[[OEXStyles sharedStyles] neutralBlackT]];
    [self.femaleButton setTintColor:[[OEXStyles sharedStyles] neutralBlackT]];
    [self selectGenderIsMale:true];
    
    UITapGestureRecognizer *termsAndPolicytapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTermsAndPolicyCheckboxTap:)];
    [self.termsAndPolicyImageView addGestureRecognizer:termsAndPolicytapGestureRecognizer];
    
    NSString* environmentName = self.environment.config.environmentName;
    if(environmentName.length > 0) {
        NSString* appVersion = [NSBundle mainBundle].oex_displayVersionString;
        self.versionLabel.text = [Strings versionDisplayWithNumber:appVersion environment:environmentName];
    }
    else {
        self.versionLabel.text = @"";
    }
    
    _placeHolderStyle = [[OEXTextStyle alloc] initWithWeight:OEXTextWeightNormal size:OEXTextSizeBase color:[[OEXStyles sharedStyles] neutralBlackT]];
    [self setAccessibilityIdentifiers];
    [self setUpAgreementTextView];
    [self setUpTermsAndPolicyTextView];
    [self updateUI:YES];
}

- (void) setupNafathRegistrationPicker {
    self.regionPickerView.items = NafathRegion.items;
    self.regionPickerView.didSelectItem = ^(PickerItem * _Nonnull item) {
        self.selectedRegion = (NafathRegion*) item;
    };
    self.regionPickerView.didDoneTapped = ^{
        [_tf_city becomeFirstResponder];
    };
    
    self.educationPickerView.items = EducationLevel.items;
    self.educationPickerView.didSelectItem = ^(PickerItem * _Nonnull item) {
        self.selectedLevelOfEducation = (EducationLevel*) item;
    };
    self.educationPickerView.didDoneTapped = ^{
        [[_englishLevelPickerView pickerTextField] becomeFirstResponder];
    };
    
    self.englishLevelPickerView.items = EnglishLanguageLevel.items;
    self.englishLevelPickerView.didSelectItem = ^(PickerItem * _Nonnull item) {
        self.selectedEnglishLanguageLevel = (EnglishLanguageLevel*) item;
    };
    self.englishLevelPickerView.didDoneTapped = ^{
        [[_employmentStatusPickerView pickerTextField] becomeFirstResponder];
    };
    
    self.employmentStatusPickerView.items = EmploymentStatus.items;
    self.employmentStatusPickerView.didSelectItem = ^(PickerItem * _Nonnull item) {
        self.selectedEmploymentStatus = (EmploymentStatus*) item;
    };
    self.employmentStatusPickerView.didDoneTapped = ^{
        [[_workExperiencePickerView pickerTextField] becomeFirstResponder];
    };
    
    self.workExperiencePickerView.items = WorkExperienceLevel.items;
    self.workExperiencePickerView.didSelectItem = ^(PickerItem * _Nonnull item) {
        self.selectedWorkExperienceLevel = (WorkExperienceLevel*) item;
    };
    self.workExperiencePickerView.didDoneTapped = ^{
        [_tf_jobTitle becomeFirstResponder];
    };
}

-(void) setUpAgreementTextView {
    [self.agreementTextView setupFor:AgreementTypeSignIn config:self.environment.config];
    self.agreementTextView.agreementDelegate = self;
    // To adjust textView according to its content size.
    self.agreementTextViewHeight.constant = self.agreementTextView.contentSize.height + [self.environment.styles standardHorizontalMargin];
}

-(void) setUpTermsAndPolicyTextView {
    [self.termsAndPolicyTextView setupFor:self.environment.config];
    self.termsAndPolicyTextView.policyDelegate = self;
}

//setting accessibility identifiers for developer automation use
- (void)setAccessibilityIdentifiers {
    self.logo_container.accessibilityIdentifier = @"LoginViewController:logo-image-view";
    self.tf_EmailID.accessibilityIdentifier = @"LoginViewController:email-text-field";
    self.tf_Password.accessibilityIdentifier = @"LoginViewController:password-text-field";
    self.agreementTextView.accessibilityIdentifier = @"LoginViewController:agreement-text-view";
    self.externalAuthContainer.accessibilityIdentifier = @"LoginViewController:external-auth-container-view";
    self.seperatorLeft.accessibilityIdentifier = @"LoginViewController:left-seperator-image-view";
    self.seperatorRight.accessibilityIdentifier = @"LoginViewController:right-seperator-image-view";
    self.btn_TroubleLogging.accessibilityIdentifier = @"LoginViewController:trouble-logging-button";
    NSString* loginIdentifier = _isNafathFlow ? @"nafath-authentication" : @"login";
    self.btn_Login.accessibilityIdentifier = [NSString stringWithFormat:@"LoginViewController:%@-button", loginIdentifier];
    self.scroll_Main.accessibilityIdentifier = @"LoginViewController:main-scroll-view";
    self.activityIndicator.accessibilityIdentifier = @"LoginViewController:activity-indicator";
    self.versionLabel.accessibilityIdentifier = @"LoginViewController:version-label";
    self.segmentControllerView.accessibilityIdentifier = @"LoginViewController:segment-controller-view";
    
    //Nafath accessibility identifiers
    self.tf_nafathID.accessibilityIdentifier = @"LoginViewController:nafath-id-text-field";
    self.tf_nafathPin.accessibilityIdentifier = @"LoginViewController:nafath-pin-text-field";
    self.tf_fullname.accessibilityIdentifier = @"LoginViewController:nafath-fullname-text-field";
    self.tf_publicUsername.accessibilityIdentifier = @"LoginViewController:nafath-public-username-text-field";
    self.tf_phone.accessibilityIdentifier = @"LoginViewController:nafath-phone-text-field";
    self.tf_city.accessibilityIdentifier = @"LoginViewController:nafath-city-text-field";
    self.tf_address.accessibilityIdentifier = @"LoginViewController:nafath-address-text-field";
    self.tf_address.accessibilityIdentifier = @"LoginViewController:nafath-address-text-field";
    self.tf_jobTitle.accessibilityIdentifier = @"LoginViewController:nafath-job-title-text-field";
    self.termsAndPolicyImageView.accessibilityIdentifier = @"LoginViewController:nafath-terms-policy-image-view";
    self.proceedButton.accessibilityIdentifier = @"LoginViewController:nafath-proceed-button";
}

- (void)navigateBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setExclusiveTouch {
    self.btn_Login.exclusiveTouch = YES;
    self.btn_TroubleLogging.exclusiveTouch = YES;
    self.view.multipleTouchEnabled = NO;
    self.view.exclusiveTouch = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Analytics Screen record
    [[OEXAnalytics sharedAnalytics] trackScreenWithName:@"Login"];
    
    OEXAppDelegate* appD = (OEXAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.reachable = [appD.reachability isReachable];
    
    [self.view setUserInteractionEnabled:YES];
    self.view.exclusiveTouch = YES;
    
    // Scrolling on keyboard hide and show
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSignInToDefaultState:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //Tap to dismiss keyboard
    UIGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(tappedToDismiss)];
    [self.view addGestureRecognizer:tapGesture];
    
    //To set all the components tot default property
    [self layoutSubviews];
    [self setToDefaultProperties];
}

- (NSString*)signInButtonText {
    return self.isNafathFlow ? [Strings nafathAuthenticateWithApp] : [Strings signInText];
}

- (NSString*)signInButtonTextOnSignIn {
    return self.isNafathFlow ? [Strings nafathAuthenticating] : [Strings signInButtonTextOnSignIn];
}

- (void)handleActivationDuringLogin {
    if(self.authProvider != nil) {
        [self setLoginDefaultState];
    }
}

- (void)setSignInToDefaultState:(NSNotification*)notification {
    OEXFBSocial *facebookManager = [[OEXFBSocial alloc]init];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if([self.authProvider isKindOfClass:[OEXGoogleAuthProvider class]] && ![[OEXGoogleSocial sharedInstance] handledOpenUrl]) {
        [self handleActivationDuringLogin];
    }
    else if(![facebookManager isLogin] && [self.authProvider isKindOfClass:[OEXFacebookAuthProvider class]]) {
        [self handleActivationDuringLogin];
    }
    [[OEXGoogleSocial sharedInstance] setHandledOpenUrl:NO];
}

- (void)setToDefaultProperties {
    self.nafathTitleLabel.attributedText = [_placeHolderStyle attributedStringWithText:[NSString stringWithFormat:@"%@ %@",[Strings nafathId],[Strings asteric]]];
    self.nafathPinTitleLabel.attributedText = [_placeHolderStyle attributedStringWithText:[NSString stringWithFormat:@"%@ %@",[Strings nafathName], @""]];
    self.fullnameLabel.attributedText = [_placeHolderStyle attributedStringWithText:[NSString stringWithFormat:@"%@ %@",[Strings nafathRegisterationFullname], [Strings asteric]]];
    self.publicUsernameLabel.attributedText = [_placeHolderStyle attributedStringWithText:[NSString stringWithFormat:@"%@ %@",[Strings nafathRegisterationPublicUsername], [Strings asteric]]];
    self.nafathEmailLabel.attributedText = [_placeHolderStyle attributedStringWithText:[NSString stringWithFormat:@"%@ %@",[Strings nafathRegisterationEmail], [Strings asteric]]];
    self.phoneLabel.attributedText = [_placeHolderStyle attributedStringWithText:[NSString stringWithFormat:@"%@ %@",[Strings nafathRegisterationPhone], [Strings asteric]]];
    self.cityLabel.attributedText = [_placeHolderStyle attributedStringWithText:[NSString stringWithFormat:@"%@ %@",[Strings nafathRegisterationCity], [Strings asteric]]];
    self.addressLabel.attributedText = [_placeHolderStyle attributedStringWithText:[NSString stringWithFormat:@"%@",[Strings nafathRegisterationAddressLine]]];
    self.jobTitleLabel.attributedText = [_placeHolderStyle attributedStringWithText:[NSString stringWithFormat:@"%@ %@",[Strings nafathRegisterationJobTitle], [Strings asteric]]];
    self.genderLabel.attributedText = [_placeHolderStyle attributedStringWithText:[NSString stringWithFormat:@"%@ %@",[Strings nafathRegisterationGender], [Strings asteric]]];
    self.dateOfBirthLabel.attributedText = [_placeHolderStyle attributedStringWithText:[NSString stringWithFormat:@"%@ %@",[Strings nafathRegisterationDateOfBirth], [Strings asteric]]];
    self.activationCodeLabel.attributedText = [_placeHolderStyle attributedStringWithText:[NSString stringWithFormat:@"%@ %@",[Strings nafathActivationCode], [Strings asteric]]];
    
    self.usernameTitleLabel.attributedText = [_placeHolderStyle attributedStringWithText:[NSString stringWithFormat:@"%@ %@",[Strings usernameTitleText],[Strings asteric]]];
    self.passwordTitleLabel.attributedText = [_placeHolderStyle attributedStringWithText:[NSString stringWithFormat:@"%@ %@",[Strings passwordTitleText],[Strings asteric]]];
    
    self.regionPickerView.title = [NSString stringWithFormat:@"%@ %@", [Strings nafathSelectRegion], [Strings asteric]];
    self.educationPickerView.title = [NSString stringWithFormat:@"%@ %@", [Strings nafathSelectEducation], [Strings asteric]];
    self.englishLevelPickerView.title = [NSString stringWithFormat:@"%@ %@", [Strings nafathSelectEnglishLanguageLevel], [Strings optional]];
    self.employmentStatusPickerView.title = [NSString stringWithFormat:@"%@ %@", [Strings nafathSelectEmploymentLevel], [Strings asteric]];
    self.workExperiencePickerView.title = [NSString stringWithFormat:@"%@ %@", [Strings nafathSelectWorkExperienceLevel], [Strings asteric]];
    
    
    self.tf_EmailID.text = @"";
    self.tf_Password.text = @"";
    // We made adjustsFontSizeToFitWidth as true to fix the dynamic type text
    self.nafathTitleLabel.adjustsFontSizeToFitWidth = true;
    self.nafathPinTitleLabel.adjustsFontSizeToFitWidth = true;
    self.usernameTitleLabel.adjustsFontSizeToFitWidth = true;
    self.passwordTitleLabel.adjustsFontSizeToFitWidth = true;
    self.nafathTitleLabel.isAccessibilityElement = false;
    self.nafathPinTitleLabel.isAccessibilityElement = false;
    self.usernameTitleLabel.isAccessibilityElement = false;
    self.passwordTitleLabel.isAccessibilityElement = false;
    self.tf_nafathID.accessibilityLabel = @"Nafath ID";
    self.tf_nafathPin.accessibilityLabel = @"Nafath Pin";
    self.tf_EmailID.accessibilityLabel = [Strings usernameTitleText];
    self.tf_Password.accessibilityLabel = [Strings passwordTitleText];
    self.tf_nafathID.accessibilityHint = [Strings accessibilityRequiredInput];
    self.tf_EmailID.accessibilityHint = [Strings accessibilityRequiredInput];
    self.tf_Password.accessibilityHint = [Strings accessibilityRequiredInput];
    OEXTextStyle *forgotButtonStyle = [[OEXTextStyle alloc] initWithWeight:OEXTextWeightBold size:OEXTextSizeBase color:[self.environment.styles infoBase]];
    [self.btn_TroubleLogging setAttributedTitle:[forgotButtonStyle attributedStringWithText:[Strings troubleInLoginButton]] forState:UIControlStateNormal];
    
    [self setLoginDefaultState];
    
    NSString* username = [[NSUserDefaults standardUserDefaults] objectForKey:USER_EMAIL];
    
    if(username) {
        _tf_EmailID.text = username;
    }
}

- (void)reachabilityDidChange:(NSNotification*)notification {
    id <Reachability> reachability = [notification object];
    
    if([reachability isReachable]) {
        self.reachable = YES;
    }
    else {
        self.reachable = NO;
        [self setLoginDefaultState];
    }
}

- (void)updateUI:(bool)isNafath {
    self.isNafathFlow = isNafath;
    self.isNafathRegistrationFlow = NO;
    self.nafathIDView.hidden = !isNafath;
    self.nafathPinView.hidden = YES;
    self.emailView.hidden = isNafath;
    self.passwordView.hidden = isNafath;
    self.btn_TroubleLogging.hidden = isNafath;
    self.externalAuthContainer.hidden = isNafath;
    self.troubleLoginButtonTop.constant = isNafath ? 0.0 : 8.0;
    self.troubleLoginButtonHeight.constant = isNafath ? 0.0 : 17.0;
    self.externalAuthContainerTop.constant = isNafath ? 0.0 : 32.0;
    self.activationCodeView.hidden = YES;
    self.btn_Login.hidden = NO;
    [self hideRegisterationFields:YES];
    
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isNafath) {
            [weakSelf.tf_nafathID becomeFirstResponder];
        } else {
            [weakSelf.tf_nafathID resignFirstResponder];
        }
    });
    
    NSString* loginIdentifier = _isNafathFlow ? @"nafath-authentication" : @"login";
    self.btn_Login.accessibilityIdentifier = [NSString stringWithFormat:@"LoginViewController:%@-button", loginIdentifier];
    [self.btn_Login applyButtonStyleWithStyle:[self.environment.styles filledPrimaryButtonStyle] withTitle:[self signInButtonText]];
    
    [self.externalAuthContainer mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo([NSNumber numberWithFloat: isNafath == YES ? 0.0 : externalAuthOptions.height]);
    }];
}

-(void)setupNafathRegistrationUI {
    self.tf_nafathID.text = @"";
    self.tf_nafathPin.text = @"";
    self.nafathIDView.hidden = YES;
    self.nafathPinView.hidden = YES;
    self.btn_Login.hidden = YES;
    self.isNafathRegistrationFlow = YES;
    [self setTitle:[Strings registerText]];
    [self.agreementTextView setupFor:AgreementTypeSignUp config:self.environment.config];
    [self hideRegisterationFields:NO];
    
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tf_fullname becomeFirstResponder];
    });
}

-(void)hideRegisterationFields:(bool)hidden {
    self.fullnameView.hidden = hidden;
    self.publicUsernameView.hidden = hidden;
    self.nafathEmailView.hidden = hidden;
    self.phoneView.hidden = hidden;
    self.regionPickerView.hidden = hidden;
    self.cityView.hidden = hidden;
    self.addressView.hidden = hidden;
    self.educationPickerView.hidden = hidden;
    self.englishLevelPickerView.hidden = hidden;
    self.employmentStatusPickerView.hidden = hidden;
    self.workExperiencePickerView.hidden = hidden;
    self.jobTitleView.hidden = hidden;
    self.genderButtonsView.hidden = hidden;
    self.termsAndPolicyView.hidden = hidden;
    self.proceedButton.hidden = hidden;
}

#pragma mark AgreementTextViewDelegate
- (void)agreementTextView:(AgreementTextView *)textView didSelect:(NSURL *)url {
    OEXUserLicenseAgreementViewController* viewController = [[OEXUserLicenseAgreementViewController alloc] initWithContentURL:url];
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark TermsAndPolicyTextViewDelegate
- (void)termsAndPolicyTextView:(TermsAndPolicyTextView *)textView didSelect:(NSURL *)url {
    OEXUserLicenseAgreementViewController* viewController = [[OEXUserLicenseAgreementViewController alloc] initWithContentURL:url];
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark SegmentControllerDelegate
- (void)segmentControllerView:(SegmentControllerView *)segmentControllerView didSelectSegmentAt:(enum Segment)segment {
    switch (segment) {
        case SegmentNafath:
            [self updateUI:YES];
            break;
        case SegmentEdx:
            if ([[OEXConfig sharedConfig] isEDXEnabled]) {
                [self updateUI:NO];
            }
            break;
        default:
            [self updateUI:YES];
            break;
    }
}

- (NSString *)segmentControllerView:(SegmentControllerView *)segmentControllerView titleForSegment:(enum Segment)segment {
    switch (segment) {
        case SegmentNafath:
            return [Strings nafathName];
        case SegmentEdx:
            if ([[OEXConfig sharedConfig] isEDXEnabled]) {
                return @"edx";
            }
            return @"";
        default:
            return @"";
    }
}

- (UIColor *)titleColorFor:(enum SegmentState)state {
    return [[OEXStyles sharedStyles] neutralBlack];
}

- (UIColor *)dividerColorFor:(enum SegmentState)state {
    switch (state) {
        case SegmentStateNormal:
            return UIColor.clearColor;
        case SegmentStateSelected:
            return [[OEXStyles sharedStyles] secondaryBaseColor];
        default:
            return UIColor.clearColor;
    }
}

- (UIFont *)fontForTitle {
    return [[OEXStyles sharedStyles] semiBoldFontOfSize:14 dynamicTypeSupported:YES];
}

- (CGFloat)paddingForSegment {
    return 0.0;
}

#pragma mark IBActions
- (void )handleTermsAndPolicyCheckboxTap:(UITapGestureRecognizer *)recognizer {
    self.isTermsAndPolicySelected = !_isTermsAndPolicySelected;
    [self.termsAndPolicyImageView setImage: self.isTermsAndPolicySelected ?
     [UIImage systemImageNamed:@"checkmark.square.fill"] :
         [UIImage systemImageNamed:@"square"]
    ];
}

- (IBAction)didMaleButtonTapped:(id)sender {
    [self selectGenderIsMale:true];
}

- (IBAction)didFemaleButtonTapped:(id)sender {
    [self selectGenderIsMale:false];
}

- (void)selectGenderIsMale:(BOOL)isMale {
    UIColor* selectedColor = [[OEXStyles sharedStyles] secondaryBaseColor];
    UIColor* unselectedColor = [[OEXStyles sharedStyles] neutralBlackT];
    
    [self.maleButton.titleLabel setTextColor:isMale ? selectedColor : unselectedColor];
    [self.maleButton setTintColor:isMale ? selectedColor : unselectedColor];
    [self.maleButton setImage:[UIImage systemImageNamed:isMale ? @"smallcircle.filled.circle" : @"circle"] forState:UIControlStateNormal];
    
    [self.femaleButton.titleLabel setTextColor:!isMale ? selectedColor : unselectedColor];
    [self.femaleButton setTintColor:!isMale ? selectedColor : unselectedColor];
    [self.femaleButton setImage:[UIImage systemImageNamed:!isMale ? @"smallcircle.filled.circle" : @"circle"] forState:UIControlStateNormal];
    
    self.selectedGender = isMale ? Gender.male : Gender.female;
}

- (IBAction)troubleLoggingClicked:(id)sender {
    if(self.reachable) {
        [[UIAlertController alloc] showInViewController:self title:[Strings resetPasswordTitle] message:[Strings resetPasswordPopupText] preferredStyle:UIAlertControllerStyleAlert cancelButtonTitle:[Strings cancel] destructiveButtonTitle:nil otherButtonsTitle:@[[Strings ok]] tapBlock:^(UIAlertController* alertController, UIAlertAction* alertAction, NSInteger buttonIndex) {
            if ( buttonIndex == 1 ) {
                UITextField* emailTextField = alertController.textFields.firstObject;
                if (!emailTextField || [emailTextField.text length] == 0 || ![emailTextField.text oex_isValidEmailAddress]) {
                    [[UIAlertController alloc] showAlertWithTitle:[Strings floatingErrorTitle] message:[Strings invalidEmailMessage] onViewController:self.navigationController];
                }
                else {
                    self.str_ForgotEmail = emailTextField.text;
                    [self presentViewController:[UIAlertController alertControllerWithTitle:[Strings resetPasswordTitle] message:[Strings waitingForResponse] preferredStyle:UIAlertControllerStyleAlert] animated:YES completion:^{
                        [self resetPassword];
                    }];
                }
            }
        } textFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.keyboardType = UIKeyboardTypeEmailAddress;
            if([self.tf_EmailID.text length] > 0) {
                [textField setAttributedPlaceholder:[_placeHolderStyle attributedStringWithText:[Strings emailAddressPrompt]]];
                textField.text = self.tf_EmailID.text;
            }
        } autoPresent:TRUE];
    }
    else {
        // error
        
        [[UIAlertController alloc] showAlertWithTitle:[Strings networkNotAvailableTitle]
                                              message:[Strings networkNotAvailableMessageTrouble]
                                     onViewController:self];
    }
}

- (IBAction)registerWithNafath:(id)sender {
    [self.view setUserInteractionEnabled:NO];
    __weak typeof (self) weakSelf = self;
    
    if(!self.reachable) {
        [[UIAlertController alloc] showAlertWithTitle:[Strings networkNotAvailableTitle]
                                              message:[Strings networkNotAvailableMessage]
                                     onViewController:weakSelf.navigationController];
        
        [self.view setUserInteractionEnabled:YES];

        return;
    }
    
    //Validation
    NSString* error = [self getRegisterationFormError];
    
    if (!error.oex_isEmpty) {
        [[UIAlertController alloc] showAlertWithTitle:[Strings floatingErrorLoginTitle]
                                              message:error
                                     onViewController:weakSelf.navigationController];
        
        error = nil;
        [self.view setUserInteractionEnabled:YES];

        return;
    }
    
    NSMutableDictionary* userData = [[NSMutableDictionary alloc] init];
    [userData setSafeObject:self.tf_nafathEmail.text forKey:@"email"];
    [userData setSafeObject:self.tf_publicUsername.text forKey:@"username"];
    [userData setSafeObject:@"" forKey:@"activation_code"];
    [userData setSafeObject:@"6" forKey:@"form"];
    
    [OEXAuthentication nafathRegisterUserWithID:self.nafathID
                                  transactionID:self.nafathTransactionID
                                       userData:userData
                              completionHandler:^(NSData * _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
        [weakSelf handleNafathUserRegisterationWith:data
                                       response:response
                                          error:error];
    }];
    
    [self setLoginInProgressState];
}

- (void)handleNafathUserRegisterationWith:(NSData*)data response:(NSURLResponse*)response error:(NSError*)error {
    
    __weak typeof (self) weakSelf = self;
    
    NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (dictionary == nil) {
        [[UIAlertController alloc] showAlertWithTitle:[Strings floatingErrorLoginTitle]
                                                                message:@"Something went wrong"
                                                       onViewController:weakSelf.navigationController];

        [self setLoginDefaultState];
        return;
    }
    NafathUserRegisteration* userRegisteration = [[NafathUserRegisteration alloc] initWithDict:dictionary];
    
    if (!error) {
        NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*) response;
        if (httpResp.statusCode == 200 || httpResp.statusCode == 201) {
            [self setLoginDefaultState];
            [self hideRegisterationFields:YES];
            [self.activationCodeView setHidden:NO];
            [self.completeButton setHidden:NO];
                        
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tf_activationCode becomeFirstResponder];
            });
        }
        else if(httpResp.statusCode == OEXHTTPStatusCode426UpgradeRequired) {
            [self showUpdateRequiredMessage];
        }
        else if (httpResp.statusCode == OEXHTTPStatusCode400BadRequest) {
            [self loginFailedWithErrorMessage:[userRegisteration error] title:nil];
        }
        else if (httpResp.statusCode == OEXHTTPStatusCode403Forbidden) {
            [self showDisabledUserMessage];
        }
        else if(httpResp.statusCode > 400 && httpResp.statusCode < 500) {
            [self loginFailedWithErrorMessage:[userRegisteration error] title:nil];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loginFailedWithErrorMessage:@"Something went wrong" title:nil];
            });
        }
    } else {
        [self loginHandleLoginError:error];
    }
}

- (NSString*) getRegisterationFormError {
    if (self.tf_fullname.text.oex_isEmpty) {
        return [NafathError fullname];
    }
    
    NSUInteger length = self.tf_publicUsername.text.length;
    if (length < 3 || length > 30) {
        return [NafathError usernameRange];
    }
    
    if (!self.tf_publicUsername.text.oex_isValidUsername) {
        return [NafathError usernameValidate];
    }
    
    if (!self.tf_nafathEmail.text.oex_isValidEmailAddress) {
        return [NafathError email];
    }
    
    if (self.tf_phone.text.oex_isEmpty) {
        return [NafathError phone];
    }
    
    if (self.selectedRegion == nil || self.selectedRegion.value.oex_isEmpty) {
        return [NafathError selectRegion];
    }
    
    if (self.tf_city.text.oex_isEmpty) {
        return [NafathError city];
    }
    
    if (self.selectedLevelOfEducation == nil || self.selectedLevelOfEducation.value.oex_isEmpty) {
        return [NafathError selectEductaion];
    }
    
    if (self.selectedEmploymentStatus == nil || self.selectedEmploymentStatus.value.oex_isEmpty) {
        return [NafathError selectEmployment];
    }
    
    if (self.selectedWorkExperienceLevel == nil || self.selectedWorkExperienceLevel.value.oex_isEmpty) {
        return [NafathError selectWorkExperience];
    }
    
    if (self.tf_jobTitle.text.oex_isEmpty) {
        return [NafathError jobTitle];
    }
    
    if (!self.isTermsAndPolicySelected) {
        return [NafathError termsAndCondition];
    }
    
    return @"";
}

- (IBAction)completeRegistrationWithNafath:(id)sender {
    [self.view setUserInteractionEnabled:NO];

    __weak typeof (self) weakSelf = self;
    if(!self.reachable) {
        [[UIAlertController alloc] showAlertWithTitle:[Strings networkNotAvailableTitle]
                                              message:[Strings networkNotAvailableMessage]
                                     onViewController:weakSelf.navigationController];
        
        [self.view setUserInteractionEnabled:YES];

        return;
    }
    
    //Validation
    if (self.tf_activationCode.text.length ==  0) {
        [[UIAlertController alloc] showAlertWithTitle:[Strings floatingErrorLoginTitle]
                                                                message:[NafathError activationCode]
                                                       onViewController:weakSelf.navigationController];

        [self.view setUserInteractionEnabled:YES];
        
        return;
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString* selectedDate = [dateFormatter stringFromDate:self.calenderDatePicker.date];
    
    NSMutableDictionary* userData = [[NSMutableDictionary alloc] init];
    [userData setSafeObject:self.tf_fullname.text forKey:@"name"];
    [userData setSafeObject:self.tf_publicUsername.text forKey:@"username"];
    [userData setSafeObject:self.tf_nafathEmail.text forKey:@"email"];
    [userData setSafeObject:self.tf_phone.text forKey:@"phone_number"];
    [userData setSafeObject:self.selectedGender.key forKey:@"gender"];
    [userData setSafeObject:selectedDate forKey:@"date_of_birth"];
    [userData setSafeObject:self.selectedRegion.key forKey:@"region"];
    [userData setSafeObject:self.tf_city.text forKey:@"city"];
    [userData setSafeObject:self.selectedLevelOfEducation.key forKey:@"level_of_education"];
    if (self.selectedEnglishLanguageLevel != nil && self.selectedEnglishLanguageLevel.key.length != 0) {
        [userData setSafeObject:self.selectedEnglishLanguageLevel.key forKey:@"english_language_level"];
    }
    [userData setSafeObject:self.selectedEmploymentStatus.key forKey:@"employment_status"];
    [userData setSafeObject:self.selectedWorkExperienceLevel.key forKey:@"work_experience_level"];
    [userData setSafeObject:self.tf_jobTitle.text forKey:@"job_title"];
    [userData setSafeObject:self.tf_activationCode.text forKey:@"activation_code"];
    [userData gck_setIntegerValue:self.calenderDatePicker.date.year forKey:@"year_of_birth"];
    
    if (self.tf_address.text.length != 0) {
        [userData setSafeObject:self.tf_address.text forKey:@"address_line"];
    }
    
    [weakSelf nafathCheckStatus:userData];
    
    [self setLoginInProgressState];
}

- (IBAction)loginClicked:(id)sender {
    [self.view setUserInteractionEnabled:NO];

    if(!self.reachable) {
        [[UIAlertController alloc] showAlertWithTitle:[Strings networkNotAvailableTitle]
                                              message:[Strings networkNotAvailableMessage]
                                     onViewController:self.navigationController
                                                            ];
        
        [self.view setUserInteractionEnabled:YES];

        return;
    }

    if (_isNafathFlow) {
        [self loginWithNafath];
    } else {
        [self loginWithEdx];
    }
}

- (void) loginWithEdx {
    if([self.tf_EmailID.text length] == 0) {
        [[UIAlertController alloc] showAlertWithTitle:[Strings floatingErrorLoginTitle]
                                                                message:[Strings enterEmail]
                                                       onViewController:self.navigationController
                                                            ];

        [self.view setUserInteractionEnabled:YES];
    }
    else if([self.tf_Password.text length] == 0) {
        [[UIAlertController alloc] showAlertWithTitle:[Strings floatingErrorLoginTitle]
                                                                message:[Strings enterPassword]
                                                       onViewController:self.navigationController
                                                            ];

        [self.view setUserInteractionEnabled:YES];
    }
    else {
        self.signInID = _tf_EmailID.text;
        self.signInPassword = _tf_Password.text;

        __weak typeof (self) weakSelf = self;
        [OEXAuthentication requestTokenWithUser:_signInID
                                       password:_signInPassword
                              completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
            [weakSelf handleLoginResponseWith:data response:response error:error];
        } ];

        [self setLoginInProgressState];
    }
}

- (void) loginWithNafath {
    __weak typeof (self) weakSelf = self;
    
    if([self.tf_nafathID.text length] == 0) {
        [[UIAlertController alloc] showAlertWithTitle:[Strings floatingErrorLoginTitle]
                                                                message:[NafathError enterNafathId]
                                                       onViewController:weakSelf.navigationController];

        [self.view setUserInteractionEnabled:YES];
    }
    else {
        if (self.nafathTransactionID.length != 0) {
            [self setLoginInProgressState];
            [self nafathCheckStatus:nil];
            return;
        }
        
        self.nafathID = self.tf_nafathID.text;
        [OEXAuthentication initiateNafathWithID:self.nafathID completionHandler:^(NSData * _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
            [weakSelf handleInitiateNafathResponseWith:data
                                          response:response
                                             error:error
            ];
        }];
        
        [self setLoginInProgressState];
    }
}

- (void)handleInitiateNafathResponseWith:(NSData*)data response:(NSURLResponse*)response error:(NSError*)error {
    
    __weak typeof (self) weakSelf = self;
 
    if(!error) {
        NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*) response;
        NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if (httpResp.statusCode == OEXHTTPStatusCode403Forbidden || dictionary == nil) {
            [self loginFailedWithErrorMessage:[NafathError unexpected] title:[Strings floatingErrorLoginTitle]];
            return;
        }
        
        NafathAuthentication* authentication = [[NafathAuthentication alloc] initWithAuthenticationDetails:dictionary];
        if(httpResp.statusCode == OEXHTTPStatusCode200OK || httpResp.statusCode == OEXHTTPStatusCode201Created) {
            [self.nafathPinView setHidden:NO];
            self.tf_nafathPin.text = authentication.random;
            self.nafathTransactionID = authentication.transId;
            [weakSelf nafathCheckStatus:nil];
        }
        else if(httpResp.statusCode == OEXHTTPStatusCode426UpgradeRequired) {
            [self showUpdateRequiredMessage];
        }
        else if (httpResp.statusCode == OEXHTTPStatusCode400BadRequest) {
            [self loginFailedWithErrorMessage:[authentication error] title:nil];
        }
        else if(httpResp.statusCode > 400 && httpResp.statusCode < 500) {
            [self loginFailedWithErrorMessage:[authentication error] ?: [NafathError unexpected] title:nil];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loginFailedWithErrorMessage:[NafathError unexpected] title:nil];
            });
        }
    }
    else {
        [self loginHandleLoginError:error];
    }
}

- (void) nafathCheckStatus:(NSDictionary* _Nullable)userData {
    __weak typeof (self) weakSelf = self;
    [OEXAuthentication nafathCheckStatusWithID:self.nafathID
                                 transactionID:self.nafathTransactionID
                                      userData:userData
                             completionHandler:^(NSData * _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
        
        [weakSelf handleNafathCheckStatusResponseWith:data
                                         response:response
                                            error:error];
        
    }];
}

- (void) handleNafathCheckStatusResponseWith:(NSData*)data response:(NSURLResponse*)response error:(NSError*)error {
    
    __weak typeof (self) weakSelf = self;
    
    if(!error) {
        NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*) response;
        NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if (httpResp.statusCode == OEXHTTPStatusCode403Forbidden || dictionary == nil) {
            [self loginFailedWithErrorMessage:[NafathError unexpected] title:[Strings floatingErrorLoginTitle]];
        }
        
        NafathCheckStatus* status = [[NafathCheckStatus alloc] initWithDict:dictionary];
        if(httpResp.statusCode == OEXHTTPStatusCode200OK || httpResp.statusCode == OEXHTTPStatusCode201Created) {
            [weakSelf handleNafathCheckStatusSuccessWith:status];
        }
        else if(httpResp.statusCode == OEXHTTPStatusCode426UpgradeRequired) {
            [self showUpdateRequiredMessage];
        }
        else if (httpResp.statusCode == OEXHTTPStatusCode400BadRequest) {
            [self loginFailedWithErrorMessage:[status error] title:nil];
        }
        else if(httpResp.statusCode > 400 && httpResp.statusCode < 500) {
            [self loginFailedWithErrorMessage:[status error] ?: [NafathError unexpected] title:nil];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf loginFailedWithErrorMessage:[NafathError unexpected] title:nil];
            });
        }
    }
    else {
        [self loginHandleLoginError:error];
    }
}

- (void) handleNafathCheckStatusSuccessWith:(NafathCheckStatus*)status {
    __weak typeof (self) weakSelf = self;
    
    if (status.error.length != 0) {
        [self loginFailedWithErrorMessage:[status error] title:nil];
    } else {
        if ([[status value]isEqualToString:@"WAITING"]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [weakSelf nafathCheckStatus:nil];
            });
        }
        else if ([[status value]isEqualToString:@"REGISTERED"]) {
            [OEXAuthentication requestTokenWithNafathID:self.nafathID
                                          transactionID:self.nafathTransactionID
                                      completionHandler:^(NSData * _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
                
                [weakSelf handleNafathLoginResponseWith:data response:response error:error];
            }];
        }
        else if ([[status value]isEqualToString:@"COMPLETED"]) {
            [self setupNafathRegistrationUI];
            [self setLoginDefaultState];
        }
        else if ([[status value]isEqualToString:@"EXPIRED"]) {
            self.nafathTransactionID = @"";
            self.tf_nafathPin.text = @"";
            [self.nafathPinView setHidden:YES];
            [self setLoginDefaultState];
        }
        else if ([[status value]isEqualToString:@"REJECTED"]) {
            self.nafathTransactionID = @"";
            self.tf_nafathPin.text = @"";
            [self.nafathPinView setHidden:YES];
            [self setLoginDefaultState];
        }
        else {
            [self setLoginDefaultState];
        }
    }
}

- (void)handleNafathLoginResponseWith:(NSData*)data response:(NSURLResponse*)response error:(NSError*)error {
    if(!error) {
        NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*) response;
        if(httpResp.statusCode == OEXHTTPStatusCode200OK) {
            [self loginSuccessful];
        }
        else if(httpResp.statusCode == OEXHTTPStatusCode426UpgradeRequired) {
            [self showUpdateRequiredMessage];
        }
        else if (httpResp.statusCode == OEXHTTPStatusCode400BadRequest) {
            [self loginFailedWithErrorMessage:[NafathError unexpected] title:nil];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loginFailedWithErrorMessage:[NafathError unexpected] title:nil];
            });
        }
    }
    else {
        [self loginHandleLoginError:error];
    }
}

- (void) setLoginInProgressState {
    [self.view setUserInteractionEnabled:NO];
    [self.activityIndicator startAnimating];
    [self.btn_Login applyButtonStyleWithStyle:[self.environment.styles filledPrimaryButtonStyle] withTitle:[self signInButtonTextOnSignIn]];
}

- (void) setLoginDefaultState {
    [self.view setUserInteractionEnabled:YES];
    [self.activityIndicator stopAnimating];
    [self.btn_Login applyButtonStyleWithStyle:[self.environment.styles filledPrimaryButtonStyle] withTitle:[self signInButtonText]];
}

- (void)handleLoginResponseWith:(NSData*)data response:(NSURLResponse*)response error:(NSError*)error {
    [[OEXGoogleSocial sharedInstance] clearHandler];

    if(!error) {
        NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*) response;
        if(httpResp.statusCode == 200) {
            [self loginSuccessful];
        }
        else if(httpResp.statusCode == OEXHTTPStatusCode426UpgradeRequired) {
            [self showUpdateRequiredMessage];
        }
        else if (httpResp.statusCode == OEXHTTPStatusCode400BadRequest && self.authProvider != nil) {
            NSString *errorMessage = [Strings authProviderErrorWithAuthProvider:self.authProvider.displayName platformName:self.environment.config.platformName];
            [self loginFailedWithErrorMessage:errorMessage title:nil];
        }
        else if (httpResp.statusCode == OEXHTTPStatusCode403Forbidden && self.authProvider != nil) {
            [self showDisabledUserMessage];
        }
        else if(httpResp.statusCode >= 400 && httpResp.statusCode < 500) {
                [self loginFailedWithErrorMessage:[Strings invalidUsernamePassword] title:nil];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loginFailedWithErrorMessage:[Strings invalidUsernamePassword] title:nil];
            });
        }
    }
    else {
        [self loginHandleLoginError:error];
    }
    self.authProvider = nil;
}

- (void)externalLoginWithProvider:(id <OEXExternalAuthProvider>)provider {
    self.authProvider = provider;
    __block BOOL isFailure = false;
    __block OEXLoginViewController *blockSelf = self;
    if(!self.reachable) {
        [[UIAlertController alloc] showAlertWithTitle:[Strings networkNotAvailableTitle]
                                                                message:[Strings networkNotAvailableMessage]
                                                       onViewController:self.navigationController
                                                            ];
        self.authProvider = nil;
        isFailure = true;
        return;
    }
    
    OEXURLRequestHandler handler = ^(NSData* data, NSHTTPURLResponse* response, NSError* error) {
        if(!response) {
            [blockSelf loginFailedWithErrorMessage:[Strings invalidUsernamePassword] title:nil];
            isFailure = true;
            return;
        }
        
        [self handleLoginResponseWith:data response:response error:error];
        self.authProvider = nil;
    };
    
    [provider authorizeServiceFromController:self
                       requestingUserDetails:NO
                              withCompletion:^(NSString* accessToken, OEXRegisteringUserDetails* details, NSError* error) {
                                  if(accessToken) {
                                      [blockSelf setLoginInProgressState];
                                      blockSelf.environment.session.thirdPartyAuthAccessToken = accessToken;
                                      [OEXAuthentication requestTokenWithProvider:provider externalToken:accessToken completion:handler];
                                  }
                                  else {
                                      handler(nil, nil, error);
                                  }
                              }];

    if (isFailure == false) {
        [self setLoginInProgressState];
    }

    isFailure = false;
}

- (void)loginHandleLoginError:(NSError*)error {
    if(error.code == -1003 || error.code == -1009 || error.code == -1005) {
        [self loginFailedWithErrorMessage:[Strings invalidUsernamePassword] title:nil];
    }
    else {
        if(error.code == 401) {
            [[OEXGoogleSocial sharedInstance] clearHandler];

            // MOB - 1110 - Social login error if the user's account is not linked with edX.
            if(self.authProvider != nil) {
                [self loginFailedWithServiceName: self.authProvider.displayName];
            }
        }
        else {
            [self loginFailedWithErrorMessage:[error localizedDescription] title: nil];
        }
    }

    [self.view setUserInteractionEnabled:YES];
}

- (void)loginFailedWithServiceName:(NSString*)serviceName {
    NSString* platform = self.environment.config.platformName;
    NSString* destination = self.environment.config.platformDestinationName;
    NSString* title = [Strings serviceAccountNotAssociatedTitleWithService:serviceName platformName:platform];
    NSString* message = [Strings serviceAccountNotAssociatedMessageWithService:serviceName platformName:platform destinationName:destination];
    [self loginFailedWithErrorMessage:message title:title];
}

- (void)loginFailedWithErrorMessage:(NSString*)errorStr title:(NSString*)title {

    if(title) {
        [[UIAlertController alloc] showAlertWithTitle:title
                                      message:errorStr
                             onViewController:self.navigationController];
    }
    else {
        [[UIAlertController alloc] showAlertWithTitle:[Strings floatingErrorLoginTitle]
                                      message:errorStr
                             onViewController:self.navigationController];
    }

    [self setLoginDefaultState];

    [self tappedToDismiss];
}

- (void) showDisabledUserMessage {
    [self setLoginDefaultState];
    [self tappedToDismiss];

    UIAlertController *alertController = [[UIAlertController alloc] showAlertWithTitle:[Strings floatingErrorLoginTitle] message:[Strings authProviderDisabledUserError] cancelButtonTitle:[Strings cancel] onViewController:self];

    __block OEXLoginViewController *blockSelf = self;
    [alertController addButtonWithTitle:[Strings customerSupport] actionBlock:^(UIAlertAction * _Nonnull action) {
        [blockSelf launchEmailComposer];
    }];
}

- (void) showUpdateRequiredMessage {
    [self setLoginDefaultState];
    [self tappedToDismiss];
    
    UIAlertController *alertController = [[UIAlertController alloc] showAlertWithTitle:nil message:[Strings versionUpgradeOutDatedLoginMessage] cancelButtonTitle:[Strings cancel] onViewController:self];
    
    [alertController addButtonWithTitle:[Strings versionUpgradeUpdate] actionBlock:^(UIAlertAction * _Nonnull action) {
        NSURL *url = _environment.config.appUpgradeConfig.iOSAppStoreURL;
        if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }];
}

- (void)loginSuccessful {
    //set global auth

    if([_tf_EmailID.text length] > 0) {
        // Set the language to blank
        [OEXInterface setCCSelectedLanguage:@""];
        [[NSUserDefaults standardUserDefaults] setObject:_tf_EmailID.text forKey:USER_EMAIL];
    }
    [self tappedToDismiss];
    [self.activityIndicator stopAnimating];

    // Analytics User Login
    [[OEXAnalytics sharedAnalytics] trackUserLogin:[self.authProvider backendName] ?: @"Password"];
    
    //Launch next view
    [self didLogin];
}

- (void)didLogin {
    [self.delegate loginViewControllerDidLogin:self];
}

#pragma mark UI

- (void)tappedToDismiss {
    [_tf_EmailID resignFirstResponder];
    [_tf_Password resignFirstResponder];
}

- (void)resetPassword {
    [OEXAuthentication resetPasswordWithEmailId:self.str_ForgotEmail completionHandler:^(NSData *data, NSURLResponse *response, NSError* error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self dismissViewControllerAnimated:YES completion:^{
                 
                 if(!error) {
                     NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                     if(httpResp.statusCode == 200) {
                         [[UIAlertController alloc]
                          showAlertWithTitle:[Strings resetPasswordConfirmationTitle]
                          message:[Strings resetPasswordConfirmationMessage] onViewController:self.navigationController];
                     }
                     else if(httpResp.statusCode <= 400 && httpResp.statusCode < 500) {
                         NSDictionary* dictionary = [NSJSONSerialization oex_JSONObjectWithData:data error:nil];
                         NSString* responseStr = [[dictionary objectForKey:@"email"] firstObject];
                         [[UIAlertController alloc]
                          showAlertWithTitle:[Strings floatingErrorTitle]
                          message:responseStr onViewController:self.navigationController];
                     }
                     else if(httpResp.statusCode >= 500) {
                         NSString* responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                         [[UIAlertController alloc] showAlertWithTitle:[Strings floatingErrorTitle] message:responseStr onViewController:self.navigationController];
                         
                     }
                 }
                 else {
                     [[UIAlertController alloc]
                      showAlertWithTitle:[Strings floatingErrorTitle] message:[error localizedDescription] onViewController:self.navigationController];
                 }
             }];
         });
     }];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    UITouch* touch = [touches anyObject];
    if([[touch view] isKindOfClass:[UIButton class]]) {
        [self.view setUserInteractionEnabled:NO];
    }
}

#pragma mark TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    if (self.isNafathRegistrationFlow) {
        if (textField == self.tf_fullname) {
            [self.tf_publicUsername becomeFirstResponder];
        } else if (textField == self.tf_publicUsername) {
            [self.tf_nafathEmail becomeFirstResponder];
        } else if (textField == self.tf_nafathEmail) {
            [self.tf_phone becomeFirstResponder];
        } else if (textField == self.tf_phone) {
            [[self.regionPickerView pickerTextField] becomeFirstResponder];
        } else if (textField == self.tf_city) {
            [self.tf_address becomeFirstResponder];
        } else if (textField == self.tf_address) {
            [[self.educationPickerView pickerTextField] becomeFirstResponder];
        }
    } else {
        if(textField == self.tf_EmailID) {
            [self.tf_Password becomeFirstResponder];
        }
        else {
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.btn_Login);
            [textField resignFirstResponder];
        }
    }

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField*)textField {
    activeField = textField;
}

#pragma mark - Scolling on Keyboard Hide/Show

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    // Calculating the height of the keyboard and the scrolling offset of the textfield
    // And scrolling on the calculated offset to make it visible

    NSDictionary* info = [aNotification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect toView:nil];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height, 0.0);
    self.scroll_Main.contentInset = contentInsets;
    self.scroll_Main.scrollIndicatorInsets = contentInsets;
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbRect.size.height;
    aRect.size.height -= activeField.frame.size.height;
    CGPoint fieldOrigin = activeField.frame.origin;
    fieldOrigin.y -= self.scroll_Main.contentOffset.y;
    fieldOrigin = [self.view convertPoint:fieldOrigin toView:self.view.superview];
    originalOffset = self.scroll_Main.contentOffset;
    if(!CGRectContainsPoint(aRect, fieldOrigin) ) {
        [self.scroll_Main scrollRectToVisible:CGRectMake(activeField.frame.origin.x, activeField.frame.origin.y, activeField.frame.size.width, activeField.frame.size.height) animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scroll_Main.contentInset = contentInsets;
    self.scroll_Main.scrollIndicatorInsets = contentInsets;
    [self.scroll_Main setContentOffset:originalOffset animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView;
{
    if(scrollView == self.scroll_Main) {
        originalOffset = scrollView.contentOffset;
    }
}

- (BOOL) isRTL {
    return [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
}

- (BOOL) shouldAutorotate {
    return true;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - Email and MFMailComposeViewControllerDelegate methods
- (void) launchEmailComposer {
    if (![MFMailComposeViewController canSendMail]) {
        [[UIAlertController alloc] showAlertWithTitle:[Strings emailAccountNotSetUpTitle] message:[Strings emailAccountNotSetUpMessage] onViewController:self.navigationController];
        return;
    }

    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    mailComposer.navigationBar.tintColor = [[OEXStyles sharedStyles] navigationItemTintColor];
    [mailComposer setSubject:[Strings accountDisabled]];
    [mailComposer setMessageBody:[EmailTemplates supportEmailMessageTemplateWithError:nil] isHTML:false];

    NSString *fbAddress = self.environment.config.feedbackEmailAddress;
    if (fbAddress) {
        [mailComposer setToRecipients:[NSArray arrayWithObject:fbAddress]];
    }

    [self presentViewController:mailComposer animated:true completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
