package test

import (
	"context"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	terra_ts "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestTerraformExamplesEphemeral(t *testing.T) {
	t.Parallel()

	workingDir := initWorkingDir(t, RootFolder, "examples/ephemeral")
	ctx := context.Background()

	localstackContainer, err := runLocalStack(ctx, LocalStackImage, LocalStackServices)
	if err != nil {
		t.Logf("failed to start container: %s", err)
	}

	awsEndpoint, err := getLocalStackEndpoint(ctx, localstackContainer)
	if err != nil {
		t.Logf("failed to get LocalStack Endpoint: %s", err)
	}

	terra_ts.RunTestStage(t, "deploy", func() {
		deploy(t, workingDir, awsEndpoint)
	})

	defer terra_ts.RunTestStage(t, "teardown", func() {
		tfOpts := terra_ts.LoadTerraformOptions(t, workingDir)
		terraform.Destroy(t, tfOpts)
		os.RemoveAll(workingDir)
		localstackContainer.Terminate(ctx)
	})

	terra_ts.RunTestStage(t, "validate_outputs", func() {
		validateOutputs(t, workingDir)
	})
}
