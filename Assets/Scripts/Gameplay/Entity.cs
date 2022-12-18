using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

[RequireComponent(typeof(Animator), typeof(Rigidbody))]
public class Entity : MonoBehaviour
{
    #region Attributes
    [SerializeField] private float _energyDivider = 5f;

    [SerializeField] private float _delayBeforeSmallJump = 0.5f;
    [SerializeField] private float _delayBeforeBigJump = 0.5f;

    [SerializeField] private ParticleSystem _fx = null;

    [Space]
    [SerializeField] private HUD _hud = null;
    [SerializeField] private EnergyManager _energyManager = null;

    private float _energy = 0f;
    private float _midEnergy = 0f;
    private Animator _animator = null;
    private Rigidbody _rigidBody = null;
    #endregion

    #region Properties
    public float Energy
    {
        get { return _energy; }
        set 
        {
            _energy = value;
        }
    }
    public float Height
    {
        get { return transform.position.y; }
    }
    #endregion

    #region Methods
    private void Awake()
    {
        _animator = GetComponent<Animator>();
        if (_animator == null)
        {
            Debug.LogError("No Component Animator found.");
            return;
        }

        _rigidBody = GetComponent<Rigidbody>();
        if (_rigidBody == null)
        {
            Debug.LogError("No Component Rigidbody found.");
            return;
        }
    }
    private void Start()
    {
        _hud.OnSliderFilled.AddListener(() => Jump(/*_energyManager.CurrentEnergy*/));
    }

    public void Jump(/*float force*/)
    {
        if (_energy > _energyManager.MidEnergy)
        {
            _animator.ResetTrigger("BigJump");
            _animator.SetTrigger("BigJump");
            StartCoroutine(AddForceCoroutine(_delayBeforeBigJump));
        }
        else
        {
            _animator.ResetTrigger("SmallJump");
            _animator.SetTrigger("SmallJump");
            StartCoroutine(AddForceCoroutine(_delayBeforeSmallJump));
        }

        _hud.CanUpdateHeight = true;
        _hud.ShowHeight(true);
    }
    private IEnumerator AddForceCoroutine(float delay)
    {
        yield return new WaitForSeconds(delay);

        _rigidBody.AddForce(Vector3.up * _energy / _energyDivider, ForceMode.Impulse);
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.tag != "Floor")
        {
            return;
        }

        _animator.SetTrigger("Idle");
        _fx.Play();
        _hud.CanUpdateHeight = false;
        _hud.ShowHeight(false);
    }
    #endregion
}
