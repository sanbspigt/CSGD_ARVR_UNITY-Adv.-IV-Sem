using UnityEngine;

public class RailCameraController : MonoBehaviour
{
    // Public variables can be set from the Unity Editor
    public CameraRail rail; // Reference to the CameraRail script that defines the path
    public float speed = 2.0f; // Speed at which the camera moves along the rail
    private float currentPos = 0.0f; // Current position of the camera along the rail, ranges from 0 to 1
    public Transform target; // Current target for the camera to look at
    public Vector3 offset; 

    public bool allowPlayerInput = true; // If true, player input can control camera movement along the rail
    public float inputSensitivity = 0.01f; // Sensitivity of the player input

    void Update()
    {
        // Check if player input is allowed
        if (allowPlayerInput)
        {
            // Get player input from the Horizontal axis (default is A/D keys or Left/Right arrows)
            float input = Input.GetAxis("Horizontal");
            // Adjust the current position along the rail based on input, scaled by sensitivity and deltaTime for frame rate independence
            currentPos += input * inputSensitivity * Time.deltaTime;
        }
        else
        {
            // If player input is not allowed, move the camera along the rail based on the speed variable
            currentPos += Time.deltaTime * speed;
        }

        // Clamp the current position to ensure it stays within the 0 to 1 range
        currentPos = Mathf.Clamp01(currentPos);

        // Update the camera's position by getting the corresponding position from the rail based on currentPos
        transform.position = offset + rail.GetPositionAt(currentPos);

        // Dynamic target tracking
        // If a target is set, make the camera look at the target
        if (target != null)
        {
            transform.LookAt(target);
        }
    }

    // Public method to change the camera's target, allowing for dynamic focus changes
    public void SetTarget(Transform newTarget)
    {
        // Update the target to the new transform
        target = newTarget;
    }
}
