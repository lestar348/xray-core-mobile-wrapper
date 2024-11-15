package XRay

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"math"
	"net"
	"net/http"
	"os"
	"runtime/debug"
	"time"

	_ "github.com/lestar348/xray-core-mobile-wrapper/all_core_packages"

	xrayNet "github.com/xtls/xray-core/common/net"
	"github.com/xtls/xray-core/core"
	"github.com/xtls/xray-core/infra/conf/serial"
)

type CompletionHandler func(int64, error)

type Logger interface {
	LogInput(s string)
}

var coreInstance *core.Instance

// Sets the limit on memory consumption by a process.
// Also set garbage collection target percentage
func SetMemoryLimit(byteLimit int64, garbageCollectionTargetPercentage int) {
	debug.SetGCPercent(garbageCollectionTargetPercentage)
	debug.SetMemoryLimit(byteLimit)
}

// Removes the memory usage limit
// and returns the garbage collector frequency to the default
func RemoveMemoryLimit() {
	debug.SetGCPercent(100)
	debug.SetMemoryLimit(math.MaxInt64)
}

// Ser AssetsDirectory in Xray env
func SetAssetsDirectory(path string) {
	os.Setenv("xray.location.asset", path)
}

// [key] can be:
// PluginLocation  = "xray.location.plugin"
// ConfigLocation  = "xray.location.config"
// ConfdirLocation = "xray.location.confdir"
// ToolLocation    = "xray.location.tool"
// AssetLocation   = "xray.location.asset"
// UseReadV         = "xray.buf.readv"
// UseFreedomSplice = "xray.buf.splice"
// UseVmessPadding  = "xray.vmess.padding"
// UseCone          = "xray.cone.disabled"
// BufferSize           = "xray.ray.buffer.size"
// BrowserDialerAddress = "xray.browser.dialer"
// XUDPLog              = "xray.xudp.show"
// XUDPBaseKey          = "xray.xudp.basekey"
func SetXrayEnv(key string, path string) {
	os.Setenv(key, path)
}

func StartXray(config []byte, logger Logger) error {
	conf, err := serial.DecodeJSONConfig(bytes.NewReader(config))
	if err != nil {
		logger.LogInput("Config load error: " + err.Error())
		return err
	}

	pbConfig, err := conf.Build()
	if err != nil {
		return err
	}
	instance, err := core.New(pbConfig)
	if err != nil {
		logger.LogInput("Create XRay error: " + err.Error())
		return err
	}

	err = instance.Start()
	if err != nil {
		logger.LogInput("Start XRay error: " + err.Error())
	}

	coreInstance = instance
	return nil
}

func StopXray() {
	coreInstance.Close()
}

// / Real ping
func MeasureOutboundDelay(config []byte, url string) (int64, error) {
	conf, err := serial.DecodeJSONConfig(bytes.NewReader(config))
	if err != nil {
		return -1, err
	}
	pbConfig, err := conf.Build()
	if err != nil {
		return -1, err
	}

	// dont listen to anything for test purpose
	pbConfig.Inbound = nil
	// config.App: (fakedns), log, dispatcher, InboundConfig, OutboundConfig, (stats), router, dns, (policy)
	// keep only basic features
	pbConfig.App = pbConfig.App[:5]

	inst, err := core.New(pbConfig)
	if err != nil {
		return -1, err
	}

	inst.Start()
	return measureInstDelay(context.Background(), inst, url)
}

func measureInstDelay(ctx context.Context, inst *core.Instance, url string) (int64, error) {
	if inst == nil {
		return -1, errors.New("core instance nil")
	}

	tr := &http.Transport{
		TLSHandshakeTimeout: 6 * time.Second,
		DisableKeepAlives:   true,
		DialContext: func(ctx context.Context, network, addr string) (net.Conn, error) {
			dest, err := xrayNet.ParseDestination(fmt.Sprintf("%s:%s", network, addr))
			if err != nil {
				return nil, err
			}
			return core.Dial(ctx, inst, dest)
		},
	}

	c := &http.Client{
		Transport: tr,
		Timeout:   12 * time.Second,
	}

	if len(url) <= 0 {
		url = "https://www.google.com/generate_204"
	}
	req, _ := http.NewRequestWithContext(ctx, "GET", url, nil)
	start := time.Now()

	resp, err := c.Do(req)
	if err != nil {
		return -1, err
	}

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusNoContent {
		return -1, fmt.Errorf("status != 20x: %s", resp.Status)
	}
	resp.Body.Close()
	return time.Since(start).Milliseconds(), nil

}
