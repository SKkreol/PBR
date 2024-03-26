                           F<               0.0.0 ţ˙˙˙      ˙˙f!ë59Ý4QÁóB   í          7  ˙˙˙˙                 Ś ˛                       E                    Ţ  #                     . ,                     5   a                    Ţ  #                     . ,                      r                    Ţ  #      	               . ,      
               H Ť ˙˙˙˙             1  1  ˙˙˙˙   @           Ţ                     Q  j                    ń  J   ˙˙˙˙   Ŕ           1  1  ˙˙˙˙               Ţ                       j  ˙˙˙˙               \     ˙˙˙˙               H r   ˙˙˙˙              1  1  ˙˙˙˙   @            Ţ                      Q  j                     H w   ˙˙˙˙              1  1  ˙˙˙˙   @            Ţ                      Q  j                     H    ˙˙˙˙              1  1  ˙˙˙˙   @            Ţ                      Q  j                     y 
                     Ţ  #      !               . ,      "                   ˙˙˙˙#   @          1  1  ˙˙˙˙$               Ţ      %               . j     &               Ő    ˙˙˙˙'               1  1  ˙˙˙˙(    Ŕ            Ţ      )                  j  ˙˙˙˙*                H   ˙˙˙˙+               1  1  ˙˙˙˙,   @            Ţ      -                Q  j     .                y 
    /                 Ţ  #      0               . ,      1                 §      2    @            ž ś      3    @            Ţ  #      4               . ,      5               H ť   ˙˙˙˙6              1  1  ˙˙˙˙7   @            Ţ      8                Q  j     9                H Ć   ˙˙˙˙:              1  1  ˙˙˙˙;   @            Ţ      <                Q  j     =                H Ř   ˙˙˙˙>              1  1  ˙˙˙˙?   @            Ţ      @                Q  j     A              MonoImporter PPtr<EditorExtension> m_FileID m_PathID PPtr<PrefabInstance> m_ExternalObjects SourceAssetIdentifier type assembly name m_UsedFileIDs m_DefaultReferences executionOrder icon m_UserData m_AssetBundleName m_AssetBundleVariant     s    ˙˙ŁGń×ÜZ56 :!@iÁJ*          7  ˙˙˙˙                 Ś ˛                        E                    Ţ                       .                      (   a                    Ţ                       .                       r                    Ţ        	               .       
               H Ť ˙˙˙˙             1  1  ˙˙˙˙   @           Ţ                     Q  j                    H ę ˙˙˙˙              1  1  ˙˙˙˙   @            Ţ                      Q  j                     ń  =   ˙˙˙˙              1  1  ˙˙˙˙               Ţ                       j  ˙˙˙˙               H   ˙˙˙˙              1  1  ˙˙˙˙   @            Ţ                      Q  j                     y 
                    Ţ                       .                      y Q                       Ţ                       .                       Ţ  X      !                H i   ˙˙˙˙"              1  1  ˙˙˙˙#   @            Ţ      $                Q  j     %                H u   ˙˙˙˙&              1  1  ˙˙˙˙'   @            Ţ      (                Q  j     )              PPtr<EditorExtension> m_FileID m_PathID PPtr<PrefabInstance> m_DefaultReferences m_Icon m_ExecutionOrder m_ClassName m_Namespace                        \       ŕyŻ     `       Ü5                                                                                                                                                ŕyŻ                                                                                    CharacterInfoViewUIController   M5  using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UI.MainMenu;
using Settings;

public class CharacterInfoViewUIController : MonoBehaviour
{
    [SerializeField] private GameObject view;

    [Header("Character")]
    [SerializeField] private Image characterAvatar;
    [SerializeField] private Image characterName;
    [SerializeField] private TextMeshProUGUI description;
    [SerializeField] private TextMeshProUGUI characterSkin;

    [Header("Weapon")]
    [SerializeField] private Image weaponIcon;
    [SerializeField] private TextMeshProUGUI weaponText;

    [Header("Buttons")]
    [SerializeField] private Button viewCharacterInfoButton;

    [Header("HealthStats")]
    [SerializeField] Image healthStatProgress;
    [SerializeField] TextMeshProUGUI healthStat;

    [Header("StaminaStats")]
    [SerializeField] Image staminaStatProgress;
    [SerializeField] TextMeshProUGUI staminaStat;

    [Header("DamageStats")]
    [SerializeField] Image damageStatProgress;
    [SerializeField] TextMeshProUGUI damageStat;

    [Header("AttackSpeedStats")]
    [SerializeField] Image attackSpeedStatProgress;
    [SerializeField] TextMeshProUGUI attackSpeedStat;

    [Header("EffectiveRange")]
    [SerializeField] Image effectiveRangeStatProgress;
    [SerializeField] TextMeshProUGUI effectiveRangeStat;

    [Header("Optional Stats Field")]
    [SerializeField] private GameObject optionalStatsPanel;
    [SerializeField] Image optionalStatProgress;
    [SerializeField] TextMeshProUGUI optionalLabel;
    [SerializeField] TextMeshProUGUI optionalStat;

    [Header("Skills")]
    [SerializeField] private Image skillContainer1;
    [SerializeField] private Image skillContainer2;
    [SerializeField] private Image skillContainer3;
    [SerializeField] private Image skillContainer4;

    [Header("Name sprites")]
    [SerializeField] private Sprite scoutName;
    [SerializeField] private Sprite minerName;
    [SerializeField] private Sprite carpenterName;
    [SerializeField] private Sprite pyromaniacName;
    [SerializeField] private Sprite commandoName;
    [SerializeField] private Sprite sniperName;
    [SerializeField] private Sprite engineerName;
    [SerializeField] private Sprite medicName;
    [SerializeField] private Sprite heavyGunnerName;
    [SerializeField] private Sprite huntressName;

    private void Awake()
    {
        viewCharacterInfoButton.onClick.AddListener(OnViewCharacterButtonCkick);
    }

    private void OnDestroy()
    {
        viewCharacterInfoButton.onClick.RemoveListener(OnViewCharacterButtonCkick);
    }

    private void OnViewCharacterButtonCkick()
    {
        MainMenuUIManager.Instance.libraryView.Open();
        MainMenuUIManager.Instance.startView.Close();
        MainMenuUIManager.Instance.CloseLoginView();
        Close();
    }

    public void Open()
    {
        view.SetActive(true);
    }

    public void Close()
    {
        view.SetActive(false);
    }

    public void InitializeCharacterInfo(NetworkUnitType type)
    {
        UnitConfig config = SettingsManager.Instance.units.GetConfig(type);       
        switch (type)
        {
            case NetworkUnitType.PlayerJohnCarpenter:
                characterAvatar.sprite = config.avatar;
                characterName.sprite = carpenterName;

                weaponText.text = $"WOOD AXE";
                weaponIcon.sprite = config.GetWeaponConfig(WeaponType.CarpenterAxe).weaponImage;

                healthStat.text = $"{config.health}";
                staminaStat.text = $"{config.stamina}";
                damageStat.text = $"{config.GetWeaponConfig(WeaponType.CarpenterAxe).meleeDamage}";
                attackSpeedStat.text = $"{config.GetWeaponConfig(WeaponType.CarpenterAxe).attackSpeed}";
                effectiveRangeStat.text = $"2m";

                optionalStatsPanel.SetActive(false);

                skillContainer1.sprite = config.GetAbilityConfig(AbilityType.Carpenter_Berserk).avatar;
                skillContainer2.sprite = config.GetAbilityConfig(AbilityType.Carpenter_Earthquake).avatar;
                skillContainer3.sprite = config.GetAbilityConfig(AbilityType.Carpenter_HeadButt).avatar;
                skillContainer4.sprite = config.GetAbilityConfig(AbilityType.Carpenter_PEDs).avatar;

                break;
            case NetworkUnitType.PlayerMiner:
                characterAvatar.sprite = config.avatar;
                characterName.sprite = minerName;

                weaponText.text = $"SHOTGUN";
                weaponIcon.sprite = config.GetWeaponConfig(WeaponType.MinerShotgun).weaponImage;

                healthStat.text = $"{config.health}";
                staminaStat.text = $"{config.stamina}";
                damageStat.text = $"{SettingsManager.Instance.bullets.GetConfig(BulletType.MinerShotgun).maxDamage}";
                attackSpeedStat.text = $"{config.GetWeaponConfig(WeaponType.MinerShotgun).attackSpeed}";
                effectiveRangeStat.text = $"{SettingsManager.Instance.bullets.GetConfig(BulletType.MinerShotgun).effectiveDistance}";

                optionalStatsPanel.SetActive(false);

                skillContainer1.sprite = config.GetAbilityConfig(AbilityType.Miner_ShotgunDash).avatar;
                skillContainer2.sprite = config.GetAbilityConfig(AbilityType.Miner_DynamiteStick).avatar;
                skillContainer3.sprite = config.GetAbilityConfig(AbilityType.Miner_Lasso).avatar;
                skillContainer4.sprite = config.GetAbilityConfig(AbilityType.Miner_Tunnel).avatar;

                break;

            case NetworkUnitType.PlayerScout:
                characterAvatar.sprite = config.avatar;
                characterName.sprite = scoutName;
                
                weaponText.text = $"RIFLE";
                weaponIcon.sprite = config.GetWeaponConfig(WeaponType.ScoutRifle).weaponImage;

                healthStat.text = $"{config.health}";
                staminaStat.text = $"{config.stamina}";
                damageStat.text = $"{SettingsManager.Instance.bullets.GetConfig(BulletType.ScoutRifle).maxDamage}";
                attackSpeedStat.text = $"{config.GetWeaponConfig(WeaponType.ScoutRifle).attackSpeed}";
                effectiveRangeStat.text = $"{SettingsManager.Instance.bullets.GetConfig(BulletType.ScoutRifle).effectiveDistance}";

                optionalStatsPanel.SetActive(false);

                skillContainer1.sprite = config.GetAbilityConfig(AbilityType.Scout_Binoculars).avatar;
                skillContainer2.sprite = config.GetAbilityConfig(AbilityType.Scout_Sprinter).avatar;
                skillContainer3.sprite = config.GetAbilityConfig(AbilityType.Scout_BeeGrenade).avatar;
                skillContainer4.sprite = config.GetAbilityConfig(AbilityType.Scout_Radar).avatar;

                break;

            case NetworkUnitType.PlayerPyromaniac:
                characterAvatar.sprite = config.avatar;
                characterName.sprite = pyromaniacName;

                weaponText.text = $"FLAMETHROWER";
                weaponIcon.sprite = config.GetWeaponConfig(WeaponType.PyromaniacFlamethrower).weaponImage;

                healthStat.text = $"{config.health}";
                staminaStat.text = $"{config.stamina}";
                damageStat.text = $"{config.GetWeaponConfig(WeaponType.PyromaniacFlamethrower).burnDamage}";
                attackSpeedStat.text = $"{config.GetWeaponConfig(WeaponType.PyromaniacFlamethrower).attackSpeed}";
                effectiveRangeStat.text = $"{config.GetWeaponConfig(WeaponType.PyromaniacFlamethrower).burnLength}";//toDo configs

                optionalStatsPanel.SetActive(false);

                skillContainer1.sprite = config.GetAbilityConfig(AbilityType.Pyromaniac_Jetpack).avatar;
                skillContainer2.sprite = config.GetAbilityConfig(AbilityType.Pyromaniac_MolotovCocktail).avatar;
                skillContainer3.sprite = config.GetAbilityConfig(AbilityType.Pyromaniac_RemotelyDetonatedMine).avatar;
                skillContainer4.sprite = config.GetAbilityConfig(AbilityType.Pyromaniac_Napalm).avatar;

                break;

            case NetworkUnitType.PlayerCommando:
                characterAvatar.sprite = config.avatar;
                characterName.sprite = commandoName;

                weaponText.text = $"KNIFE";
                weaponIcon.sprite = config.GetWeaponConfig(WeaponType.CommandoKnife).weaponImage;

                healthStat.text = $"{config.health}";
                staminaStat.text = $"{config.stamina}";
                damageStat.text = $"{config.GetWeaponConfig(WeaponType.CommandoKnife).meleeDamage}";
                attackSpeedStat.text = $"{config.GetWeaponConfig(WeaponType.CommandoKnife).attackSpeed}";
                effectiveRangeStat.text = $"2m";

                optionalStatsPanel.SetActive(false);

                skillContainer1.sprite = config.GetAbilityConfig(AbilityType.Commando_Assassination).avatar;
                skillContainer2.sprite = config.GetAbilityConfig(AbilityType.Commando_Camouflaged).avatar;
                skillContainer3.sprite = config.GetAbilityConfig(AbilityType.Commando_ChokeBomb).avatar;
                skillContainer4.sprite = config.GetAbilityConfig(AbilityType.Commando_SpyCamera).avatar;

                break;

            case NetworkUnitType.PlayerSniper:
                characterAvatar.sprite = config.avatar;
                characterName.sprite = sniperName;

                weaponText.text = $"SNIPER RIFLE";
                weaponIcon.sprite = config.GetWeaponConfig(WeaponType.SniperRifle).weaponImage;

                healthStat.text = $"{config.health}";
                staminaStat.text = $"{config.stamina}";
                damageStat.text = $"{SettingsManager.Instance.bullets.GetConfig(BulletType.SniperRifle).maxDamage}";
                attackSpeedStat.text = $"{config.GetWeaponConfig(WeaponType.SniperRifle).attackSpeed}";
                effectiveRangeStat.text = $"{SettingsManager.Instance.bullets.GetConfig(BulletType.SniperRifle).effectiveDistance}";

                optionalStatsPanel.SetActive(false);

                skillContainer1.sprite = config.GetAbilityConfig(AbilityType.Sniper_GuerillaCape).avatar;
                skillContainer2.sprite = config.GetAbilityConfig(AbilityType.Sniper_ExplosiveShell).avatar;
                skillContainer3.sprite = config.GetAbilityConfig(AbilityType.Sniper_Silencer).avatar;
                skillContainer4.sprite = config.GetAbilityConfig(AbilityType.Sniper_Perch).avatar;

                break;

            case NetworkUnitType.PlayerEngineer:
                characterAvatar.sprite = config.avatar;
                characterName.sprite = engineerName;

                weaponText.text = $"TESLA GUN";
                weaponIcon.sprite = config.GetWeaponConfig(WeaponType.EngineerTeslaGun).weaponImage;

                healthStat.text = $"{config.health}";
                staminaStat.text = $"{config.stamina}";
                damageStat.text = $"{40}";
                attackSpeedStat.text = $"{config.GetWeaponConfig(WeaponType.EngineerTeslaGun).attackSpeed}";
                effectiveRangeStat.text = $"{100}";

                optionalStatsPanel.SetActive(false);
                break;

            case NetworkUnitType.PlayerMedic:

                characterAvatar.sprite = config.avatar;
                characterName.sprite = medicName;

                weaponText.text = $"PISTOL";
                weaponIcon.sprite = config.GetWeaponConfig(WeaponType.ScoutRifle).weaponImage;

                healthStat.text = $"{config.health}";
                staminaStat.text = $"{config.stamina}";
                damageStat.text = $"{40}";
                attackSpeedStat.text = $"{config.GetWeaponConfig(WeaponType.ScoutRifle).attackSpeed}";
                effectiveRangeStat.text = $"{100}";

                optionalStatsPanel.SetActive(false);
                