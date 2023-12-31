GOMOBILE=gomobile
GOBIND=$(GOMOBILE) bind
BUILDDIR=$(shell pwd)/build
IOS_ARTIFACT=$(BUILDDIR)/XRayCoreIOSWrapper.xcframework
ANDROID_ARTIFACT=$(BUILDDIR)/xray.aar

IOS_TARGET=ios/arm64
IOS_SIMULATOR_TARGET=iossimulator
MACOS_TARGET=macos

IOS_VERSION=12.0
ANDROID_TARGET=android
# LDFLAGS='-s -w -X google.golang.org/protobuf/reflect/protoregistry.conflictPolicy=warn'
LDFLAGS='-s -w -extldflags -lresolv'
IMPORT_PATH=github.com/lestar348/xray-core-mobile-wrapper

BUILD_IOS="cd $(BUILDDIR) && $(GOBIND) -a -ldflags $(LDFLAGS) -target=$(IOS_TARGET),$(IOS_SIMULATOR_TARGET) -o $(IOS_ARTIFACT) $(IMPORT_PATH)"
BUILD_IOS_SIMULATOR="cd $(BUILDDIR) && $(GOBIND) -a -ldflags $(LDFLAGS) -target=$(IOS_SIMULATOR_TARGET) -o $(IOS_ARTIFACT) $(IMPORT_PATH)" 

BUILD_MACOS ="cd $(BUILDDIR) && $(GOBIND) -a -ldflags $(LDFLAGS) -target=$(MACOS_TARGET) -o $(IOS_ARTIFACT) $(IMPORT_PATH)" 

BUILD_ANDROID="cd $(BUILDDIR) && $(GOBIND) -a -ldflags $(LDFLAGS) -target=$(ANDROID_TARGET) -tags=gomobile -o $(ANDROID_ARTIFACT) $(IMPORT_PATH)"

all: ios android

ios:
	mkdir -p $(BUILDDIR)
	eval $(BUILD_IOS)

macos:
	mkdir -p $(BUILDDIR)
	eval $(BUILD_MACOS)

android:
	rm -rf $(BUILDDIR) 2>/dev/null
	mkdir -p $(BUILDDIR)
	eval $(BUILD_ANDROID)

clean:
	rm -rf $(BUILDDIR)
