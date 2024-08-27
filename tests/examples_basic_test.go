package test

import (
	"fmt"
	"os"
	"strings"
	"testing"

	terra_rand "github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	terra_ts "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

const (
	RootFolder string = ".."
)

func initWorkingDir(t *testing.T, rootFolder, terraformFolderRelativeToRoot string) string {
	return terra_ts.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)
}

func deploy(t *testing.T, workingDir string) {
	attribute := strings.ToLower(terra_rand.UniqueId())
	terra_ts.SaveString(t, workingDir, "attribute", attribute)

	tfOpts := terraform.WithDefaultRetryableErrors(
		t,
		&terraform.Options{
			TerraformDir: workingDir,
			Vars: map[string]interface{}{
				"attributes": []string{attribute},
			},
		},
	)

	terra_ts.SaveTerraformOptions(t, workingDir, tfOpts)
	terraform.InitAndApply(t, tfOpts)
}

func validateOutputs(t *testing.T, workingDir string) {
	tfOpts := terra_ts.LoadTerraformOptions(t, workingDir)
	attribute := terra_ts.LoadString(t, workingDir, "attribute")

	output := terraform.Output(t, tfOpts, "id")
	assert.Equal(t, fmt.Sprintf("sweetops-production-aweasome-%s", attribute), output)
}

func TestTerraformExamplesBasic(t *testing.T) {
	t.Parallel()

	workingDir := initWorkingDir(t, RootFolder, "examples/basic")

	terra_ts.RunTestStage(t, "deploy", func() {
		deploy(t, workingDir)
	})

	defer terra_ts.RunTestStage(t, "teardown", func() {
		tfOpts := terra_ts.LoadTerraformOptions(t, workingDir)
		terraform.Destroy(t, tfOpts)
		os.RemoveAll(workingDir)
	})

	terra_ts.RunTestStage(t, "validate_outputs", func() {
		validateOutputs(t, workingDir)
	})
}
