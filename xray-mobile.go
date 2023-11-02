package XRay

import (
	"bytes"
	"runtime/debug"

	_ "github.com/xtls/xray-core/main/distro/all"

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
