using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class HUD : MonoBehaviour
{
    #region Attributes
    [SerializeField] private string _heightFormat = "Height reached : {0}";

    [SerializeField] private TextMeshProUGUI _heightText = null;

    [Space]
    [SerializeField] private GameButton _resetButton = null;
    [SerializeField] private GameButton _confirmButton = null;

    [Space]
    [SerializeField] private Slider _strengthSlider = null;
    [SerializeField] private Slider _energySlider = null;
    #endregion

    #region Methods
    private void Start()
    {

    }
    private void Update()
    {

    }

    private void OnEnergyValueChanged(float value)
    {
    }

    private void ShowHeight(float height)
    {
        _heightText.text = string.Format(_heightFormat, height);
    }
    #endregion
}
