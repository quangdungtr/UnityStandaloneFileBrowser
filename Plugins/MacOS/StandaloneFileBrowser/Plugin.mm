#include "Plugin.pch"

static BOOL IsEditor;
static MonoDomain *monoDomain;
static MonoAssembly *monoAssembly;
static MonoImage *monoImage;
static MonoMethodDesc *monoDesc;
static MonoMethod *monoMethod;

static void UnitySendMessage(const char *gameObject, const char *method, const char *message) {
    if (monoMethod == 0) {
        NSString *assemblyPath;
        if (IsEditor) {
            assemblyPath = @"Library/ScriptAssemblies/Assembly-CSharp-firstpass.dll";
        } else {
            NSString *dllPath = @"Contents/Resources/Data/Managed/Assembly-CSharp-firstpass.dll";
            assemblyPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:dllPath];
        }
        monoDomain = mono_domain_get();
        monoDesc = mono_method_desc_new("UnitySendMessageDispatcher:Dispatch(string,string,string)", FALSE);

        monoAssembly = mono_domain_assembly_open(monoDomain, [assemblyPath UTF8String]);

        if (monoAssembly != 0) {
            monoImage = mono_assembly_get_image(monoAssembly);
            monoMethod = mono_method_desc_search_in_image(monoDesc, monoImage);
        }

        if (monoMethod == 0) {
            if (IsEditor) {
                assemblyPath = @"Library/ScriptAssemblies/Assembly-CSharp.dll";
            } else {
                NSString *dllPath = @"Contents/Resources/Data/Managed/Assembly-CSharp.dll";
                assemblyPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:dllPath];
            }
            monoAssembly = mono_domain_assembly_open(monoDomain, [assemblyPath UTF8String]);

            if (monoAssembly != 0) {
                monoImage = mono_assembly_get_image(monoAssembly);
                monoMethod = mono_method_desc_search_in_image(monoDesc, monoImage);
            }
        }
    }

    if (monoMethod == 0) {
        return;
    }

    void *args[] = {
        mono_string_new(monoDomain, gameObject),
        mono_string_new(monoDomain, method),
        mono_string_new(monoDomain, message),
    };
    
    mono_runtime_invoke(monoMethod, 0, args, 0);
}

const char* DialogOpenFilePanel(const char* title,
                                const char* directory,
                                const char* filters,
                                bool multiselect) {
    StandaloneFileBrowser* dialog = [[StandaloneFileBrowser alloc] init];
    NSString* paths = [dialog dialogOpenFilePanel:[NSString stringWithUTF8String:title]
                                        directory:[NSString stringWithUTF8String:directory]
                                          filters:[NSString stringWithUTF8String:filters]
                                      multiselect:multiselect
                                   canChooseFiles:YES
                                 canChooseFolders:NO];
    return [paths UTF8String];
}

void DialogOpenFilePanelAsync(bool isEditor,
                              const char* goName,
                              const char* methodName,
                              const char* title,
                              const char* directory,
                              const char* filters,
                              bool multiselect) {
    IsEditor = isEditor;
    StandaloneFileBrowser* dialog = [[StandaloneFileBrowser alloc] init];
    [dialog dialogOpenFilePanelAsync:[NSString stringWithUTF8String:goName]
                          methodName:[NSString stringWithUTF8String:methodName]
                               title:[NSString stringWithUTF8String:title]
                           directory:[NSString stringWithUTF8String:directory]
                             filters:[NSString stringWithUTF8String:filters]
                         multiselect:multiselect
                      canChooseFiles:YES
                    canChooseFolders:NO];
}

const char* DialogOpenFolderPanel(const char* title,
                                  const char* directory,
                                  bool multiselect) {
    StandaloneFileBrowser* dialog = [[StandaloneFileBrowser alloc] init];
    NSString* paths = [dialog dialogOpenFilePanel:[NSString stringWithUTF8String:title]
                                        directory:[NSString stringWithUTF8String:directory]
                                          filters:[NSString stringWithUTF8String:""]
                                      multiselect:multiselect
                                   canChooseFiles:NO
                                 canChooseFolders:YES];
    return [paths UTF8String];
}

void DialogOpenFolderPanelAsync(bool isEditor,
                                const char* goName,
                                const char* methodName,
                                const char* title,
                                const char* directory,
                                bool multiselect) {
    IsEditor = isEditor;
    StandaloneFileBrowser* dialog = [[StandaloneFileBrowser alloc] init];
    [dialog dialogOpenFilePanelAsync:[NSString stringWithUTF8String:goName]
                          methodName:[NSString stringWithUTF8String:methodName]
                               title:[NSString stringWithUTF8String:title]
                           directory:[NSString stringWithUTF8String:directory]
                             filters:[NSString stringWithUTF8String:""]
                         multiselect:multiselect
                      canChooseFiles:NO
                    canChooseFolders:YES];
}

const char* DialogSaveFilePanel(const char* title,
                                const char* directory,
                                const char* defaultName,
                                const char* filters) {
    StandaloneFileBrowser* dialog = [[StandaloneFileBrowser alloc] init];
    NSString* paths = [dialog dialogSaveFilePanel:[NSString stringWithUTF8String:title]
                                        directory:[NSString stringWithUTF8String:directory]
                                      defaultName:[NSString stringWithUTF8String:defaultName]
                                          filters:[NSString stringWithUTF8String:filters]];
    return [paths UTF8String];
}

void DialogSaveFilePanelAsync(bool isEditor,
                              const char* goName,
                              const char* methodName,
                              const char* title,
                              const char* directory,
                              const char* defaultName,
                              const char* filters) {
    IsEditor = isEditor;
    StandaloneFileBrowser* dialog = [[StandaloneFileBrowser alloc] init];
    [dialog dialogSaveFilePanelAsync:[NSString stringWithUTF8String:goName]
                          methodName:[NSString stringWithUTF8String:methodName]
                               title:[NSString stringWithUTF8String:title]
                           directory:[NSString stringWithUTF8String:directory]
                         defaultName:[NSString stringWithUTF8String:defaultName]
                             filters:[NSString stringWithUTF8String:filters]];
}


@implementation StandaloneFileBrowser

- (id)init {
    if (self = [super init]) {
        NSLog(@"init");
    }
    return self;
}

- (NSString*)dialogOpenFilePanel:(NSString*)title
                       directory:(NSString*)directory
                         filters:(NSString*)filters
                     multiselect:(BOOL)multiselect
                  canChooseFiles:(BOOL)canChooseFiles
                canChooseFolders:(BOOL)canChooseFolders {

    NSOpenPanel* panel = [self createOpenPanel:title
                                     directory:directory
                                       filters:filters
                                   multiselect:multiselect
                                canChooseFiles:canChooseFiles
                              canChooseFolders:canChooseFolders];
    if (panel && [panel runModal] == NSFileHandlingPanelOKButton) {
        if ([[panel URLs] count] > 0) {
            NSString* seperator = [NSString stringWithFormat:@"%c", 28];
            return [[panel URLs] componentsJoinedByString:seperator];
        }
    }

    return @"";
}

- (void)dialogOpenFilePanelAsync:(NSString*)goName
                      methodName:(NSString*)methodName
                           title:(NSString*)title
                       directory:(NSString*)directory
                         filters:(NSString*)filters
                     multiselect:(BOOL)multiselect
                  canChooseFiles:(BOOL)canChooseFiles
                canChooseFolders:(BOOL)canChooseFolders {

    NSOpenPanel* panel = [self createOpenPanel:title
                                     directory:directory
                                       filters:filters
                                   multiselect:multiselect
                                canChooseFiles:canChooseFiles
                              canChooseFolders:canChooseFolders];
    if (panel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([panel runModal] == NSFileHandlingPanelOKButton) {
                if ([[panel URLs] count] > 0) {
                    NSString* seperator = [NSString stringWithFormat:@"%c", 28];
                    NSString* paths = [[panel URLs] componentsJoinedByString:seperator];
                    UnitySendMessage([goName UTF8String], [methodName UTF8String], [paths UTF8String]);
                    return;
                }
            }
            UnitySendMessage([goName UTF8String], [methodName UTF8String], [@"" UTF8String]);
        });
    }
    else {
        UnitySendMessage([goName UTF8String], [methodName UTF8String], [@"" UTF8String]);
    }
}

- (NSOpenPanel*)createOpenPanel:(NSString*)title
                      directory:(NSString*)directory
                        filters:(NSString*)filters
                    multiselect:(BOOL)multiselect
                 canChooseFiles:(BOOL)canChooseFiles
               canChooseFolders:(BOOL)canChooseFolders {
    @try {
        NSMutableArray* filterItems = [[NSMutableArray alloc] init];
        NSMutableArray* extensions = [[NSMutableArray alloc] init];
        [self parseFilter:filters filters:filterItems extensions:extensions];

        NSOpenPanel* panel = [NSOpenPanel openPanel];

        if (filterItems.count > 0) {
            PopUpButtonHandler* popUpHandler = [[PopUpButtonHandler alloc] initWithPanel:panel];
            [popUpHandler setExtensions:extensions];

            NSView *accessoryView = [[NSView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 200, 24.0)];
            NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 60, 22)];
            [label setEditable:NO];
            [label setStringValue:@"File type:"];
            [label setBordered:NO];
            [label setBezeled:NO];
            [label setDrawsBackground:NO];

            NSPopUpButton *popupButton = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(61.0, 2, 140, 22.0) pullsDown:NO];
            [popupButton addItemsWithTitles:filterItems];
            [popupButton setTarget:popUpHandler];
            [popupButton setAction:@selector(selectFormatOpen:)];

            [accessoryView addSubview:label];
            [accessoryView addSubview:popupButton];

            [panel setAccessoryView:accessoryView];
            if ([panel respondsToSelector:@selector(setAccessoryViewDisclosed:)]) {
                [panel setAccessoryViewDisclosed:YES];
            }
            [panel setAllowedFileTypes:(NSArray*)[extensions objectAtIndex:0]];
        }

        if ([title length] != 0) {
            [panel setMessage:title];
        }
        [panel setCanChooseFiles:canChooseFiles];
        [panel setCanChooseDirectories:canChooseFolders];
        [panel setAllowsMultipleSelection:multiselect];
        [panel setDirectoryURL:[NSURL fileURLWithPath:directory]];

        return panel;
    }
    @catch (NSException *exception) {
        NSLog(@"SFB::dialogOpenFilePanel Exception: %@", exception.reason);
        return nil;
    }
}

- (NSString*)dialogSaveFilePanel:(NSString*)title
                       directory:(NSString*)directory
                     defaultName:(NSString*)defaultName
                         filters:(NSString*)filters {
    NSSavePanel* panel = [self createSavePanel:title
                                     directory:directory
                                   defaultName:defaultName
                                       filters:filters];
    if (panel && [panel runModal] == NSFileHandlingPanelOKButton) {
        NSURL *URL = [panel URL];
        if (URL) {
            return [URL path];
        }
    }

    return @"";
}

- (void)dialogSaveFilePanelAsync:(NSString*)goName
                      methodName:(NSString*)methodName
                           title:(NSString*)title
                       directory:(NSString*)directory
                     defaultName:(NSString*)defaultName
                         filters:(NSString*)filters {
    NSSavePanel* panel = [self createSavePanel:title
                                     directory:directory
                                   defaultName:defaultName
                                       filters:filters];
    if (panel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([panel runModal] == NSFileHandlingPanelOKButton) {
                NSURL *URL = [panel URL];
                if (URL) {
                    UnitySendMessage([goName UTF8String], [methodName UTF8String], [[URL path] UTF8String]);
                    return;
                }
            }
            UnitySendMessage([goName UTF8String], [methodName UTF8String], [@"" UTF8String]);
        });
    }
    else {
        UnitySendMessage([goName UTF8String], [methodName UTF8String], [@"" UTF8String]);
    }
}


- (NSSavePanel*)createSavePanel:(NSString*)title
                      directory:(NSString*)directory
                    defaultName:(NSString*)defaultName
                        filters:(NSString*)filters {
    @try {
        NSMutableArray* filterItems = [[NSMutableArray alloc] init];
        NSMutableArray* extensions = [[NSMutableArray alloc] init];
        [self parseFilter:filters filters:filterItems extensions:extensions];

        NSSavePanel* panel = [NSSavePanel savePanel];

        if (filterItems.count > 0) {
            PopUpButtonHandler* popupHandler = [[PopUpButtonHandler alloc] initWithPanel:panel];
            [popupHandler setExtensions:extensions];

            NSView *accessoryView = [[NSView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 220, 24.0)];
            NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 80, 22)];
            [label setEditable:NO];
            [label setStringValue:@"Save as type:"];
            [label setBordered:NO];
            [label setBezeled:NO];
            [label setDrawsBackground:NO];

            NSPopUpButton *popupButton = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(81.0, 2, 140, 22.0) pullsDown:NO];
            [popupButton addItemsWithTitles:filterItems];
            [popupButton setTarget:popupHandler];
            [popupButton setAction:@selector(selectFormatSave:)];

            [accessoryView addSubview:label];
            [accessoryView addSubview:popupButton];

            [panel setAccessoryView:accessoryView];
            [panel setAllowedFileTypes:(NSArray*)[extensions objectAtIndex:0]];
        }

        if ([title length] != 0) {
            [panel setMessage:title];
        }
        [panel setDirectoryURL:[NSURL fileURLWithPath:directory]];
        [panel setNameFieldStringValue:defaultName];

        return panel;
    }
    @catch (NSException *exception) {
        NSLog(@"SFB::dialogSaveFilePanel Exception%@", exception.reason);
        return nil;;
    }
}


- (void)parseFilter:(NSString*)filter filters:(NSMutableArray*)filters extensions:(NSMutableArray*)extensions {
    if ([filter length] == 0) {
        return;
    }

    @try {
        NSArray* fileFilters = [filter componentsSeparatedByString:@"|"];
        for (NSString* filter in fileFilters) {
            NSArray* f = [filter componentsSeparatedByString:@";"];
            NSString* filterName = (NSString*)[f objectAtIndex:0];

            NSString* extNames = (NSString*)[f objectAtIndex:1];
            NSArray* exts = [extNames componentsSeparatedByString:@","];

            NSMutableString* filterItemName = [[NSMutableString alloc] init];
            [filterItemName appendFormat:@"%@ (", filterName];
            for (NSString* ext in exts) {
                [filterItemName appendFormat:@"*.%@,", ext];
            }
            [filterItemName deleteCharactersInRange:NSMakeRange([filterItemName length]-1, 1)];
            [filterItemName appendString:@")"];

            [filters addObject:filterItemName];
            [extensions addObject:exts];
        }
    } @catch (NSException *exception) {
        NSLog(@"SFB::parseFilter Exception%@", exception.reason);
    }
}

@end

@implementation PopUpButtonHandler

- (id)initWithPanel:(NSPanel*)panel {
    self = [super init];
    if (self) {
        _panel = panel;
    }
    return self;
}

- (void)setExtensions:(NSArray *)extensions {
    _extensions = extensions;
}

- (void)selectFormatOpen:(id)sender {
    NSPopUpButton* button = (NSPopUpButton *)sender;
    NSInteger selectedItemIndex = [button indexOfSelectedItem];

    NSString* firstExtension = (NSString*)[[_extensions objectAtIndex:selectedItemIndex] objectAtIndex:0];
    if ([firstExtension isEqualToString:@""] || [firstExtension isEqualToString:@"*"]) {
        [((NSOpenPanel*)_panel) setAllowedFileTypes:nil];
    }
    else {
        [((NSOpenPanel*)_panel) setAllowedFileTypes:[_extensions objectAtIndex:selectedItemIndex]];
    }
}

- (void)selectFormatSave:(id)sender {
    NSPopUpButton* button = (NSPopUpButton *)sender;
    NSInteger selectedItemIndex = [button indexOfSelectedItem];
    NSString* nameFieldString = [((NSSavePanel*)_panel) nameFieldStringValue];
    NSString* trimmedNameFieldString = [nameFieldString stringByDeletingPathExtension];

    NSString* ext = [[_extensions objectAtIndex:selectedItemIndex] objectAtIndex:0];
    NSString* nameFieldStringWithExt = nil;

    if ([ext isEqualToString:@""] || [ext isEqualToString:@"*"]) {
        nameFieldStringWithExt = trimmedNameFieldString;
        [((NSSavePanel*)_panel) setAllowedFileTypes:nil];
    }
    else {
        nameFieldStringWithExt = [NSString stringWithFormat:@"%@.%@", trimmedNameFieldString, ext];
        [((NSSavePanel*)_panel) setAllowedFileTypes:@[ext]];
    }
    
    [((NSSavePanel*)_panel) setNameFieldStringValue:nameFieldStringWithExt];
}

@end
