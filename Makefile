GOMOBILE=gomobile
GOBIND=$(GOMOBILE) bind

BUILDDIR=$(shell pwd)/build
BUILDDIR_IOS=$(BUILDDIR)/ios
BUILDDIR_MACOS=$(BUILDDIR)/macos
BUILDDIR_ANDROID=$(BUILDDIR)/android

IOS_ARTIFACT=$(BUILDDIR)/XRayCoreIOSWrapper.xcframework
ANDROID_ARTIFACT=$(BUILDDIR)/xray.aar

IOS_TARGET=ios/arm64
IOS_SIMULATOR_TARGET=iossimulator
MACOS_TARGET=macos

IOS_VERSION=12.0
ANDROID_API=24
# LDFLAGS='-s -w -X google.golang.org/protobuf/reflect/protoregistry.conflictPolicy=warn'
LDFLAGS='-s -w -extldflags -lresolv'
IMPORT_PATH=github.com/lestar348/xray-core-mobile-wrapper

BUILD_IOS="cd $(BUILDDIR) && $(GOBIND) -a -ldflags $(LDFLAGS) -target=$(IOS_TARGET),$(IOS_SIMULATOR_TARGET) -o $(IOS_ARTIFACT) $(IMPORT_PATH)"
BUILD_IOS_SIMULATOR="cd $(BUILDDIR) && $(GOBIND) -a -ldflags $(LDFLAGS) -target=$(IOS_SIMULATOR_TARGET) -o $(IOS_ARTIFACT) $(IMPORT_PATH)" 

BUILD_MACOS ="cd $(BUILDDIR) && $(GOBIND) -a -ldflags $(LDFLAGS) -target=$(MACOS_TARGET) -o $(IOS_ARTIFACT) $(IMPORT_PATH)" 

BUILD_ANDROID="cd $(BUILDDIR_ANDROID) && $(GOBIND) -v -androidapi $(ANDROID_API) -ldflags='-s -w' $(IMPORT_PATH)"

all: ios android macos

ios:
	mkdir -p $(BUILDDIR_IOS)
	eval $(BUILD_IOS)

macos:
	mkdir -p $(BUILDDIR_MACOS)
	eval $(BUILD_MACOS)

android:
	mkdir -p $(BUILDDIR_ANDROID)
	eval $(BUILD_ANDROID)

clean:
	rm -rf $(BUILDDIR)
