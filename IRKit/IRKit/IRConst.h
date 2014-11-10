#ifndef IRKit_IRConst_h
#define IRKit_IRConst_h

#pragma mark - UITableViewCell identifiers

#define IRKitCellIdentifierSignal                             @"IRSignalCell"
#define IRKitCellIdentifierPeripheral                         @"IRPeripheralCell"
#define IRKitCellIdentifierEdit                               @"IREditCell"

#pragma mark - IR*ViewControllerDelegate

#define IRViewControllerResultType                            @"result"
#define IRViewControllerResultTypeCancelled                   @"cancelled"
#define IRViewControllerResultTypeDone                        @"done"
#define IRViewControllerResultPeripheral                      @"peripheral"
#define IRViewControllerResultSignal                          @"signal"
#define IRViewControllerResultText                            @"text"
#define IRViewControllerResultKeys                            @"keys"

#pragma mark - Errors

#define IRKitErrorDomain                                      @"irkit"
#define IRKitErrorDomainHTTP                                  @"irkit.http"

#define IRKitHTTPStatusCodeUnknown                            999

#pragma mark - URLs

#define STATICENDPOINT_BASE                                   @"http://getirkit.com"
#define APIENDPOINT_BASE                                      @"https://api.getirkit.com"
#define APIENDPOINT_APPS                                      @"http://api.getirkit.com/1/apps/recommended"

#pragma mark - Notifications

extern NSString *const IRClientDidRegisterNotification;

#endif // ifndef IRKit_IRConst_h
