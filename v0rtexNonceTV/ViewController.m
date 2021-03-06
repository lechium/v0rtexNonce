//
//  ViewController.m
//  v0rtexNonceTV
//
//  Created by Kevin Bradley on 12/26/17.
//  Copyright © 2017 ninja. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *generatorLabel;
@property (weak, nonatomic) IBOutlet UITextField *generatorInput;
@end

@implementation ViewController
- (IBAction)generatorInputActionTrigger:(id)sender
{
    /*
     
     this code is different from the ViewController.m in the iOS version because
     no matter what i did it always told me my generator was invalid with the
     current code in view controller for iOS, this is what the view controller used to
     do in an earlier version
     
     */
    const char *generator = [_generatorInput.text UTF8String];
    char compareString[22];
    char generatorToSet[22];
    uint64_t rawGeneratorValue;
    NSLog(@"gen length: %lu", strlen(generator));
    switch(strlen(generator))
    {
        case 16:
            sscanf(generator, "%llx", &rawGeneratorValue);
            sprintf(compareString, "%llx", rawGeneratorValue);
            break;
            
        case 18:
            sscanf(generator, "0x%16llx", &rawGeneratorValue);
            sprintf(compareString, "0x%llx", rawGeneratorValue);
            break;
            
        case 19:
            sscanf(generator, "0x%17llx", &rawGeneratorValue);
            sprintf(compareString, "0x%llx", rawGeneratorValue);
            break;
            
        default:
            LOG("Invalid generator\n");
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Error" message:@"The generator you entered is invalid" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [ac addAction:cancel];
            [self presentViewController:ac animated:true completion:nil];
            break;
    }
    if(!strcmp(compareString, generator))
    {
        sprintf(generatorToSet, "0x%llx", rawGeneratorValue);
        LOG("generator to set : %s\n", generatorToSet);
        if(set_generator(generatorToSet))
        {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Success" message:@"The generator has been set" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [ac addAction:cancel];
            [self presentViewController:ac animated:true completion:nil];
        }
    }
    else
    {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to validate generator" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [ac addAction:cancel];
        [self presentViewController:ac animated:true completion:nil];
       
    }
    NSString *currentGenerator = [self getGenerator];
    _generatorLabel.text = _generatorLabel.text = [currentGenerator length] < 2 ? @"-unavailable-" : currentGenerator;;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if(getuid() != 0)
    {
        if(party_hard())
        {
            
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Error" message:@"v0rtex exploit failed\nPlease reboot and try again" preferredStyle:UIAlertControllerStyleAlert];
            
            [self presentViewController:ac animated:true completion:nil];
            
            
        }
    }
    NSString *currentGenerator = [self getGenerator];
    _generatorLabel.text = [currentGenerator length] < 2 ? @"-unavailable-" : currentGenerator;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)getGenerator
{
    NSString *bootNonce = [[NSMutableString alloc] initWithString:@""];
    CFMutableDictionaryRef bdict = IOServiceMatching("IODTNVRAM");
    io_service_t nvservice = IOServiceGetMatchingService(kIOMasterPortDefault, bdict);
    
    if(MACH_PORT_VALID(nvservice))
    {
        io_string_t buffer;
        unsigned int len = 256;
        kern_return_t kret = IORegistryEntryGetProperty(nvservice, "com.apple.System.boot-nonce", buffer, &len);
        if(kret == KERN_SUCCESS)
        {
            bootNonce = [NSString stringWithFormat:@"%s", (char *) buffer];
        }
        else
        {
            LOG("Reading var failed");
        }
    }
    else
    {
        LOG("Failed to get IODTNVRAM");
    }
    LOG("current generator: %@", bootNonce);
    return bootNonce;
}

@end
