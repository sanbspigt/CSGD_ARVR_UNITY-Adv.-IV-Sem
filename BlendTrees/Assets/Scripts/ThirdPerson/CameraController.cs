using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    [SerializeField] Transform followTarget;

    [SerializeField] float rotationSpeed = 2f;
    [SerializeField] float distance = 5f;

    [SerializeField] float minVerticalAngle = -45f;
    [SerializeField] float maxVerticalAngle = 45f;

    [SerializeField] Vector2 framingOffset;

    [SerializeField] bool invertX;
    [SerializeField] bool invertY;

    float rotationX;
    float rotationY;

    float invertXVal;
    float invertYVal;

    private void Start()
    {
        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;
    }

    private void Update()
    {
        invertXVal = (invertX) ? -1 : 1;
        invertYVal = (invertY) ? -1 : 1;

        // Adjust rotationX (vertical look) based on mouse input, clamped within the specified vertical angle range
        rotationX += Input.GetAxis("Mouse Y") * invertYVal * rotationSpeed;
        rotationX = Mathf.Clamp(rotationX, minVerticalAngle, maxVerticalAngle);

        // Adjust rotationY (horizontal look) based on mouse input, allowing free rotation around the Y axis
        rotationY += Input.GetAxis("Mouse X") * invertXVal * rotationSpeed;

        // Calculate target rotation based on adjusted X and Y rotations
        var targetRotation = Quaternion.Euler(rotationX, rotationY, 0);

        // Calculate focus position based on the target and any framing offsets
        var focusPosition = followTarget.position + new Vector3(framingOffset.x, framingOffset.y);

        // Adjust the camera position based on the calculated target rotation and distance from the focus position
        transform.position = focusPosition - targetRotation * new Vector3(0, 0, distance);
        transform.LookAt(focusPosition); // Ensure the camera always looks at the focus position
    }

    public Quaternion PlanarRotation => Quaternion.Euler(0, rotationY, 0);
}
