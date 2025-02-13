
GOMOBILE_REPO = https://github.com/protonjohn/gomobile.git
GOMOBILE_TV_OS_BRANCH = pr/jkb/add-tvos-xros-support

BUILDDIR=$(shell pwd)/build
BUILDDIR_GOMOBILE=$(BUILDDIR)/gomobile
BUILDDIR_GOMOBILE_CMD=$(BUILDDIR_GOMOBILE)/cmd/gomobile

GOMOBILE=$(BUILDDIR)/gomobile_with_tvos
GOBIND=$(GOMOBILE) bind

BUILDDIR_IOS=$(BUILDDIR)/ios
BUILDDIR_MACOS=$(BUILDDIR)/macos
BUILDDIR_ANDROID=$(BUILDDIR)/android

APPLE_ARTIFACT=$(BUILDDIR)/XRayCoreIOSWrapper.xcframework
ANDROID_ARTIFACT=$(BUILDDIR)/xray.aar

IOS_TARGET=ios/arm64
TV_OS_TARGET=appletvos
TV_OS_SIMULATOR_TARGET=appletvsimulator
IOS_SIMULATOR_TARGET=iossimulator
MACOS_TARGET=macos
MACOSX_TARGET=maccatalyst

IOS_VERSION=14.0
ANDROID_API=24

LDFLAGS='-s -w -extldflags -lresolv'
IMPORT_PATH=github.com/lestar348/xray-core-mobile-wrapper

BUILD_GOMOBILE = "cd $(BUILDDIR) && git clone $(GOMOBILE_REPO) && cd $(BUILDDIR_GOMOBILE) && git checkout $(GOMOBILE_TV_OS_BRANCH) && cd $(BUILDDIR_GOMOBILE_CMD) && go build -o $(GOMOBILE)"

BUILD_ANDROID="cd $(BUILDDIR_ANDROID) && $(GOBIND) -v -androidapi $(ANDROID_API) -ldflags='-s -w' $(IMPORT_PATH)"

BUILD_IOS="cd $(BUILDDIR) && $(GOBIND) -a -ldflags $(LDFLAGS) -target=$(IOS_TARGET),$(IOS_SIMULATOR_TARGET) -o $(APPLE_ARTIFACT) $(IMPORT_PATH)"
BUILD_IOS_SIMULATOR="cd $(BUILDDIR) && $(GOBIND) -a -ldflags $(LDFLAGS) -target=$(IOS_SIMULATOR_TARGET) -o $(APPLE_ARTIFACT) $(IMPORT_PATH)" 

BUILD_MACOS ="cd $(BUILDDIR) && $(GOBIND) -a -ldflags $(LDFLAGS) -target=$(MACOS_TARGET) -o $(APPLE_ARTIFACT) $(IMPORT_PATH)" 

BUILD_ALL_APPLE_PLATFORMS = "cd $(BUILDDIR) && $(GOBIND) -a -ldflags $(LDFLAGS) -target=$(TV_OS_TARGET),$(TV_OS_SIMULATOR_TARGET),$(IOS_TARGET),$(IOS_SIMULATOR_TARGET),$(MACOS_TARGET) -o $(APPLE_ARTIFACT) $(IMPORT_PATH)"

gomobiletvos:
	mkdir -p $(BUILDDIR)	
	eval $(BUILD_GOMOBILE)

all:  clean gomobiletvos allapple 

allapple:	
	eval $(BUILD_ALL_APPLE_PLATFORMS)

ios:
	gomobiletvos
	mkdir -p $(BUILDDIR_IOS)
	eval $(BUILD_IOS)

macos:
	gomobiletvos
	mkdir -p $(BUILDDIR_MACOS)
	eval $(BUILD_MACOS)

android:
	gomobile
	mkdir -p $(BUILDDIR_ANDROID)
	eval $(BUILD_ANDROID)

clean:
	rm -rf $(BUILDDIR)
