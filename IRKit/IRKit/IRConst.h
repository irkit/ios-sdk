#ifndef IRKit_IRConst_h
#define IRKit_IRConst_h

#pragma mark - NSNotification names

// discovered unauthenticated peripheral
#define IRKitDidDiscoverUnauthenticatedPeripheralNotification @"IRKit::DiscoveredUnauthenticated"

// user authenticated peripheral for the 1st time
#define IRKitDidAuthenticatePeripheralNotification            @"IRKit::Authenticated"

// connected to peripheral and ready to send
#define IRKitDidConnectPeripheralNotification              @"IRKit::DidConnect"
#define IRKitDidDisconnectPeripheralNotification           @"IRKit::DidDisconnect"
#define IRKitDidReceiveSignalNotification                  @"IRKit::ReceivedSignal"

#define IRKitSignalUserInfoKey                   @"signal"

#pragma mark - UITableViewCell identifiers

#define IRKitCellIdentifierSignal                          @"IRSignalCell"
#define IRKitCellIdentifierPeripheral                      @"IRPeripheralCell"
#define IRKitCellIdentifierEdit                            @"IREditCell"

#pragma mark - IR*ViewControllerDelegate

#define IRViewControllerResultType           @"result"
#define IRViewControllerResultTypeCancelled  @"cancelled"
#define IRViewControllerResultTypeDone       @"done"
#define IRViewControllerResultPeripheral     @"peripheral"
#define IRViewControllerResultSignal         @"signal"
#define IRViewControllerResultText           @"text"
#define IRViewControllerResultKeys           @"keys"

#pragma mark - Errors

#define IRKitErrorDomain              @"irkit"
#define IRKitErrorDomainHTTP          @"irkit.http"
#define IRKIT_ERROR_CODE_NOT_READY      1
#define IRKIT_ERROR_CODE_DISCONNECTED   2
#define IRKIT_ERROR_CODE_C12C_NOT_FOUND 3

#define IRKitHTTPStatusCodeUnknown 999

#pragma mark - URLs

#define ONURL_BASE @"http://getirkit.appspot.com"

#endif
