package XRay

import (
	"bytes"
	"os"
	"runtime/debug"

	_ "github.com/lestar348/xray-core-mobile-wrapper/all_core_packages"

	"github.com/xtls/xray-core/core"
	"github.com/xtls/xray-core/infra/conf/serial"
)

type Logger interface {
	LogInput(s string)
}

var coreInstance *core.Instance

func SetMemoryLimit() {
	debug.SetGCPercent(10)
	debug.SetMemoryLimit(30 * 1024 * 1024)
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
